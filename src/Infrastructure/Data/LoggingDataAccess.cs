using System.Data;
using System.Diagnostics;
using Dapper;
using Microsoft.Data.Sqlite;
using System.Linq;
using System.Threading;

namespace Infrastructure.Data;

public class LoggingDataAccess
{
    private readonly SqliteConnectionFactory _factory;

    public LoggingDataAccess(SqliteConnectionFactory factory)
    {
        _factory = factory;
    }

    public IDbConnection CreateConnection() => _factory.CreateConnection();

    private static readonly SemaphoreSlim _migrationLock = new(1, 1);
    private static bool _schemaEnsured;

    public async Task EnsureSchemaAsync()
    {
        if (_schemaEnsured) return;
        await _migrationLock.WaitAsync();
        try
        {
            if (_schemaEnsured) return;

            using var connection = _factory.CreateConnection();
            await ((SqliteConnection)connection).OpenAsync();
            using var transaction = connection.BeginTransaction();

            var columns = (await connection.QueryAsync("PRAGMA table_info(entries);", transaction: transaction)).ToList();
            var hasTags = columns.Any(c => string.Equals((string)c.name, "tags", StringComparison.OrdinalIgnoreCase));
            if (columns.Any() && !hasTags)
            {
                try
                {
                    await connection.ExecuteAsync("ALTER TABLE entries ADD COLUMN tags TEXT NOT NULL DEFAULT '';", transaction: transaction);
                }
                catch (SqliteException ex) when (ex.Message.Contains("duplicate", StringComparison.OrdinalIgnoreCase))
                {
                    // ignore if column already exists
                }
            }

            transaction.Commit();
            _schemaEnsured = true;
        }
        finally
        {
            _migrationLock.Release();
        }
    }

    public async Task InitializeAsync()
    {
        await EnsureSchemaAsync();
        using var connection = _factory.CreateConnection();
        var sql = @"CREATE TABLE IF NOT EXISTS query_audit (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            query TEXT NOT NULL,
            duration_ms INTEGER NOT NULL,
            executed_at TEXT NOT NULL
        );";
        await connection.ExecuteAsync(sql);
    }

    private async Task LogAsync(IDbConnection connection, string query, long durationMs)
    {
        var sql = "INSERT INTO query_audit (query, duration_ms, executed_at) VALUES (@Query, @Duration, @ExecutedAt)";
        await connection.ExecuteAsync(sql, new
        {
            Query = query,
            Duration = durationMs,
            ExecutedAt = DateTime.UtcNow
        });
    }

    public async Task<int> ExecuteAsync(string sql, object? param = null)
    {
        using var connection = _factory.CreateConnection();
        var sw = Stopwatch.StartNew();
        var result = await connection.ExecuteAsync(sql, param);
        sw.Stop();
        await LogAsync(connection, sql, sw.ElapsedMilliseconds);
        return result;
    }

    public async Task<T> ExecuteScalarAsync<T>(string sql, object? param = null)
    {
        using var connection = _factory.CreateConnection();
        var sw = Stopwatch.StartNew();
        var result = await connection.ExecuteScalarAsync<T>(sql, param);
        sw.Stop();
        await LogAsync(connection, sql, sw.ElapsedMilliseconds);
        return result;
    }

    public async Task<IEnumerable<T>> QueryAsync<T>(string sql, object? param = null)
    {
        using var connection = _factory.CreateConnection();
        var sw = Stopwatch.StartNew();
        var result = await connection.QueryAsync<T>(sql, param);
        sw.Stop();
        await LogAsync(connection, sql, sw.ElapsedMilliseconds);
        return result;
    }

    public async Task<T?> QuerySingleOrDefaultAsync<T>(string sql, object? param = null)
    {
        using var connection = _factory.CreateConnection();
        var sw = Stopwatch.StartNew();
        var result = await connection.QuerySingleOrDefaultAsync<T>(sql, param);
        sw.Stop();
        await LogAsync(connection, sql, sw.ElapsedMilliseconds);
        return result;
    }
}
