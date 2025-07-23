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

var provider = services.BuildServiceProvider();

var repo = provider.GetRequiredService<ITodoRepository>();
await repo.InitializeAsync();

var id = await repo.AddAsync(new TodoItem { Title = "Learn Dapper", IsCompleted = false });
Console.WriteLine($"Inserted Todo with Id {id}");

var items = await repo.GetAllAsync();
foreach (var item in items)
{
    Console.WriteLine($"{item.Id}: {item.Title} - {(item.IsCompleted ? "Done" : "Pending")}");
}
