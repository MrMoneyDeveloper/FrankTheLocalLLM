using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;
using Infrastructure.Repositories;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

var configuration = new ConfigurationBuilder()
    .AddJsonFile("appsettings.json", optional: true)
    .AddEnvironmentVariables()
    .Build();

var services = new ServiceCollection();

var connectionString = configuration.GetConnectionString("Default") ?? "Data Source=app.db";
services.AddSingleton(new SqliteConnectionFactory(connectionString));
services.AddScoped<ITodoRepository, TodoRepository>();
services.AddScoped<IUserRepository, UserRepository>();

var provider = services.BuildServiceProvider();

var todoRepo = provider.GetRequiredService<ITodoRepository>();
await todoRepo.InitializeAsync();

var todoId = await todoRepo.AddAsync(new TodoItem { Title = "Learn Dapper", IsCompleted = false });
Console.WriteLine($"Inserted Todo with Id {todoId}");

var items = await todoRepo.GetAllAsync();
foreach (var item in items)
{
    Console.WriteLine($"{item.Id}: {item.Title} - {(item.IsCompleted ? "Done" : "Pending")}");
}

var userRepo = provider.GetRequiredService<IUserRepository>();
await userRepo.InitializeAsync();
var userId = await userRepo.AddAsync(new User { Username = "alice", Email = "alice@example.com", CreatedAt = DateTime.UtcNow });
Console.WriteLine($"Inserted User with Id {userId}");
var stats = await userRepo.GetStatsAsync(userId);
if (stats != null)
{
    Console.WriteLine($"Stats for {stats.Username}: Entries={stats.EntryCount}, Tasks={stats.TaskCount}");
}
