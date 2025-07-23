using Dapper;
using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;

namespace Infrastructure.Repositories;

public class UserRepository : IUserRepository
{
    private readonly SqliteConnectionFactory _connectionFactory;

    public UserRepository(SqliteConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task InitializeAsync()
    {
        using var connection = _connectionFactory.CreateConnection();
        var sql = @"
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            email TEXT NOT NULL,
            created_at TEXT NOT NULL
        );
        CREATE TABLE IF NOT EXISTS entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            content TEXT NOT NULL,
            created_at TEXT NOT NULL,
            FOREIGN KEY(user_id) REFERENCES users(id)
        );
        CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            is_done INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            FOREIGN KEY(user_id) REFERENCES users(id)
        );
        CREATE TABLE IF NOT EXISTS llm_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            prompt TEXT NOT NULL,
            response TEXT NOT NULL,
            created_at TEXT NOT NULL,
            FOREIGN KEY(user_id) REFERENCES users(id)
        );
        CREATE VIEW IF NOT EXISTS user_stats AS
            SELECT u.id AS UserId, u.username AS Username,
                COUNT(DISTINCT e.id) AS EntryCount,
                COUNT(DISTINCT t.id) AS TaskCount
            FROM users u
                LEFT JOIN entries e ON e.user_id = u.id
                LEFT JOIN tasks t ON t.user_id = u.id
            GROUP BY u.id;
        ";
        await connection.ExecuteAsync(sql);
    }

    public async Task<int> AddAsync(User user)
    {
        using var connection = _connectionFactory.CreateConnection();
        var sql = "INSERT INTO users (username, email, created_at) VALUES (@Username, @Email, @CreatedAt); SELECT last_insert_rowid();";
        var id = await connection.ExecuteScalarAsync<long>(sql, user);
        return (int)id;
    }

    public async Task<User?> GetByIdAsync(int id)
    {
        using var connection = _connectionFactory.CreateConnection();
        var sql = "SELECT id as Id, username as Username, email as Email, created_at as CreatedAt FROM users WHERE id = @Id";
        return await connection.QuerySingleOrDefaultAsync<User>(sql, new { Id = id });
    }

    public async Task<IEnumerable<User>> GetAllAsync()
    {
        using var connection = _connectionFactory.CreateConnection();
        var sql = "SELECT id as Id, username as Username, email as Email, created_at as CreatedAt FROM users";
        return await connection.QueryAsync<User>(sql);
    }

    public async Task UpdateAsync(User user)
    {
        using var connection = _connectionFactory.CreateConnection();
        var sql = "UPDATE users SET username = @Username, email = @Email WHERE id = @Id";
        await connection.ExecuteAsync(sql, user);
    }

    public async Task DeleteAsync(int id)
    {
        using var connection = _connectionFactory.CreateConnection();
        var sql = "DELETE FROM users WHERE id = @Id";
        await connection.ExecuteAsync(sql, new { Id = id });
    }

    public async Task<UserStats?> GetStatsAsync(int userId)
    {
        using var connection = _connectionFactory.CreateConnection();
        var sql = "SELECT UserId, Username, EntryCount, TaskCount FROM user_stats WHERE UserId = @UserId";
        return await connection.QuerySingleOrDefaultAsync<UserStats>(sql, new { UserId = userId });
    }
}
