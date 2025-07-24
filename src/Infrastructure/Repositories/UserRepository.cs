using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;
using Dapper;

namespace Infrastructure.Repositories;

public class UserRepository : BaseRepository<User>, IUserRepository
{
    public UserRepository(LoggingDataAccess db) : base(db, "users")
    {
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

    public async Task<UserStats?> GetStatsAsync(int userId)
    {
        var sql = "SELECT UserId, Username, EntryCount, TaskCount FROM user_stats WHERE UserId = @UserId";
        return await _db.QuerySingleOrDefaultAsync<UserStats>(sql, new { UserId = userId });
    }
}
