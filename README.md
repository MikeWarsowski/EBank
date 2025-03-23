# WBank - Banking Management System

A web-based banking management system built with Flask and SQL Server, allowing employees to manage customer accounts, process transactions, and track banking operations.

## Features

- Employee Authentication
- Customer Account Management
- Transaction Processing (Deposits and Withdrawals)
- Transaction History Tracking
- Customer and Employee Search
- Real-time Balance Updates

## Technology Stack

- Backend: Python/Flask
- Database: Microsoft SQL Server
- Frontend: HTML, CSS (Bootstrap), JavaScript
- Authentication: Session-based

## Prerequisites

- Python 3.8+
- Microsoft SQL Server
- pip (Python package manager)

## Installation

1. Clone the repository:
```bash
git clone <your-repository-url>
cd wbank
```

2. Create a virtual environment and activate it:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Set up your environment variables in a `.env` file:
```
SECRET_KEY=your-secret-key-here
```

5. Initialize the database:
- Run the SQL scripts in the following order:
  1. `add_balance_column.sql`
  2. `add_employee_auth.sql`

## Running the Application

1. Activate the virtual environment:
```bash
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Run the Flask application:
```bash
python app.py
```

3. Access the application at `http://localhost:5000`

## Usage

1. Log in using employee credentials
2. Search for customers or employees
3. Process transactions:
   - Make deposits
   - Process withdrawals
   - View transaction history

## Security Notes

- This is a development version. For production:
  - Implement proper password hashing
  - Use HTTPS
  - Add rate limiting
  - Implement additional security measures

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 