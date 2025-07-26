use std::process::{Command, Stdio};
use std::io::{BufRead, BufReader};
use std::sync::Mutex;
use tauri::{self, State};

struct BackendPort(Mutex<u16>);


fn main() {
    let mut child = Command::new("python")
        .arg("../backend/main.py")
        .stdout(Stdio::piped())
        .spawn()
        .expect("failed to spawn backend");

    let stdout = child.stdout.take().expect("no stdout");
    let mut reader = BufReader::new(stdout);
    let mut line = String::new();
    reader.read_line(&mut line).expect("read line");
    let port: u16 = line.trim().parse().expect("parse port");

    tauri::Builder::default()
        .manage(BackendPort(Mutex::new(port)))
        .run(tauri::generate_context!())
        .expect("error running tauri app");
}
