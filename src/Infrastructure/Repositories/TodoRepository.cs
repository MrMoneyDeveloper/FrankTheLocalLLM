using Dapper;
using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;

namespace Infrastructure.Repositories;

public class TodoRepository : ITodoRepository
{
    private readonly SqliteConnectionFactory _connectionFactory;

    public TodoRepository(SqliteConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task InitializeAsync()
    {
        using var connection = _connectionFactory.CreateConnection();
        var query = @"CREATE TABLE IF NOT EXISTS Todos (
            Id INTEGER PRIMARY KEY AUTOINCREMENT,
            Title TEXT NOT NULL,
            IsCompleted INTEGER NOT NULL
        );";
        await connection.ExecuteAsync(query);
    }

    public async Task<int> AddAsync(TodoItem item)
    {
        using var connection = _connectionFactory.CreateConnection();
        var sql = "INSERT INTO Todos (Title, IsCompleted) VALUES (@Title, @IsCompleted); SELECT last_insert_rowid();";
        var id = await connection.ExecuteScalarAsync<long>(sql, item);
        return (int)id;
    }

    public async Task<IEnumerable<TodoItem>> GetAllAsync()
    {
        using var connection = _connectionFactory.CreateConnection();
        var sql = "SELECT Id, Title, IsCompleted FROM Todos";
        return await connection.QueryAsync<TodoItem>(sql);
    }
}
