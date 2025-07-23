using Dapper;
using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;
using Infrastructure.QueryBuilders;

namespace Infrastructure.Repositories;

public class EntryRepository : IEntryRepository
{
    private readonly LoggingDataAccess _db;

    public EntryRepository(LoggingDataAccess db)
    {
        _db = db;
    }

    public async Task InitializeAsync()
    {
        var sql = @"CREATE TABLE IF NOT EXISTS entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            content TEXT NOT NULL,
            tags TEXT,
            created_at TEXT NOT NULL,
            FOREIGN KEY(user_id) REFERENCES users(id)
        );";
        await _db.ExecuteAsync(sql);
    }

    public async Task<int> AddAsync(Entry entry)
    {
        var sql = "INSERT INTO entries (user_id, content, tags, created_at) VALUES (@UserId, @Content, @Tags, @CreatedAt); SELECT last_insert_rowid();";
        var id = await _db.ExecuteScalarAsync<long>(sql, entry);
        return (int)id;
    }

    public async Task<IEnumerable<Entry>> QueryAsync(EntryQueryOptions options)
    {
        var builder = new EntryQueryBuilder(options);
        var (sql, parameters) = builder.Build();
        return await _db.QueryAsync<Entry>(sql, parameters);
    }
}
