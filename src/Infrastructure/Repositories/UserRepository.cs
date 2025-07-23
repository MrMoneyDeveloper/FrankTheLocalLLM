using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;
using Dapper;

namespace Infrastructure.Repositories;

public class UserRepository : IUserRepository
{
    private readonly LoggingDataAccess _db;

    public UserRepository(LoggingDataAccess db)
    {
        _db = db;
    }

    public async Task InitializeAsync()
    {
        var sql = @"
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            email TEXT NOT NULL,
            created_at TEXT NOT NULL
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
            model TEXT,
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
            GROUP BY u.id;";
        await _db.ExecuteAsync(sql);
    }

    public async Task<int> AddAsync(User user)
    {
        var sql = "INSERT INTO users (username, email, created_at) VALUES (@Username, @Email, @CreatedAt); SELECT last_insert_rowid();";
        var id = await _db.ExecuteScalarAsync<long>(sql, user);
        return (int)id;
    }

    public async Task<User?> GetByIdAsync(int id)
    {
        var sql = "SELECT id as Id, username as Username, email as Email, created_at as CreatedAt FROM users WHERE id = @Id";
        return await _db.QuerySingleOrDefaultAsync<User>(sql, new { Id = id });
    }

    public async Task<IEnumerable<User>> GetAllAsync()
    {
        var sql = "SELECT id as Id, username as Username, email as Email, created_at as CreatedAt FROM users";
        return await _db.QueryAsync<User>(sql);
    }

    public async Task UpdateAsync(User user)
    {
        var sql = "UPDATE users SET username = @Username, email = @Email WHERE id = @Id";
        await _db.ExecuteAsync(sql, user);
    }

    public async Task DeleteAsync(int id)
    {
        var sql = "DELETE FROM users WHERE id = @Id";
        await _db.ExecuteAsync(sql, new { Id = id });
    }

    public async Task<UserStats?> GetStatsAsync(int userId)
    {
        var sql = "SELECT UserId, Username, EntryCount, TaskCount FROM user_stats WHERE UserId = @UserId";
        return await _db.QuerySingleOrDefaultAsync<UserStats>(sql, new { UserId = userId });
    }
}
