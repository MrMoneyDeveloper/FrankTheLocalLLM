using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;

namespace Infrastructure.Repositories;

public class TodoRepository : ITodoRepository
{
    private readonly LoggingDataAccess _db;

    public TodoRepository(LoggingDataAccess db)
    {
        _db = db;
    }

    public async Task InitializeAsync()
    {
        var query = @"CREATE TABLE IF NOT EXISTS Todos (
            Id INTEGER PRIMARY KEY AUTOINCREMENT,
            Title TEXT NOT NULL,
            IsCompleted INTEGER NOT NULL
        );";
        await _db.ExecuteAsync(query);
    }

    public async Task<int> AddAsync(TodoItem item)
    {
        var sql = "INSERT INTO Todos (Title, IsCompleted) VALUES (@Title, @IsCompleted); SELECT last_insert_rowid();";
        var id = await _db.ExecuteScalarAsync<long>(sql, item);
        return (int)id;
    }

    public async Task<IEnumerable<TodoItem>> GetAllAsync()
    {
        var sql = "SELECT Id, Title, IsCompleted FROM Todos";
        return await _db.QueryAsync<TodoItem>(sql);
    }
}
