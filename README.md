# Database Management System Using Bash Script

## Overview

This project is a simple Database Management System (DBMS) implemented using Bash Scripting on Linux. It allows users to create and manage databases and tables through a command-line interface without using any external database engine.

The project demonstrates the use of shell scripting, file handling, data validation, and menu-driven programming.

---

## Features

### Database Operations
- Create Database
- List Databases
- Connect to Database
- Drop Database

### Table Operations
- Create Table
- List Tables
- Drop Table
- Insert Record
- Select Records
- Update Records
- Delete Records

---

## Table Structure

Each table supports:

- Multiple columns
- User-defined column names
- Data type validation
- Primary Key constraint
- Metadata storage

---

## Technologies Used

- Bash Scripting
- Linux
- Shell Commands
- CSV Files

---

## Project Structure

```text
DBMS/
│
├── databases/
│   ├── Database1/
│   │   ├── employees
│   │   └── employees.schema
│   │
│   └── Database2/
│
└── mainScreen.sh
```

---

## How It Works

### Database Management
Databases are represented as directories.

### Table Management
Tables are stored as files, while table metadata (column names, data types, and primary key information) is stored separately.

### Data Validation
The system validates:

- Data types
- Empty values
- Primary Key uniqueness

---

## Run The Project

```bash
chmod +x mainScreen.sh
./mainScreen.sh
```

