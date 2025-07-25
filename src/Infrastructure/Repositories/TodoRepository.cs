using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;

namespace Infrastructure.Repositories;

public class TodoRepository : BaseRepository<TodoItem>, ITodoRepository
{
    public TodoRepository(LoggingDataAccess db) : base(db, "todos")
    {
    }

    public async Task InitializeAsync()
    {
        var query = @"CREATE TABLE IF NOT EXISTS todos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            is_completed INTEGER NOT NULL
        );";
        await _db.ExecuteAsync(query);
    }

}
