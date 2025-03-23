from flask import Flask, render_template, request, jsonify, session, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import os
from dotenv import load_dotenv
from decimal import Decimal
from functools import wraps

load_dotenv()

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'mssql+pymssql://localhost/WBank'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'your-secret-key-here')  # Add this for session management
db = SQLAlchemy(app)

# Login required decorator
def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'employee_id' not in session:
            return jsonify({'error': 'Authentication required'}), 401
        return f(*args, **kwargs)
    return decorated_function

# Database Models
class Location(db.Model):
    __tablename__ = 'Locations'
    LocationID = db.Column(db.Integer, primary_key=True)
    LocationCode = db.Column(db.String(50), unique=True, nullable=False)
    Address = db.Column(db.String(255), nullable=False)
    City = db.Column(db.String(100), nullable=False)
    State = db.Column(db.String(2), nullable=False)

class AccountType(db.Model):
    __tablename__ = 'AccountType'
    AccountTypeID = db.Column(db.Integer, primary_key=True)
    AccountType = db.Column(db.String(50), unique=True, nullable=False)

class Employee(db.Model):
    __tablename__ = 'Employees'
    EmployeeID = db.Column(db.Integer, primary_key=True)
    EmployeeNumber = db.Column(db.String(50), unique=True, nullable=False)
    FirstName = db.Column(db.String(100), nullable=False)
    LastName = db.Column(db.String(100), nullable=False)
    Title = db.Column(db.String(50), nullable=False)
    CanCreateNewAccount = db.Column(db.Boolean, default=False, nullable=False)
    HourlySalary = db.Column(db.Numeric(10, 2), nullable=False)
    Address = db.Column(db.String(255), nullable=False)
    City = db.Column(db.String(100), nullable=False)
    State = db.Column(db.String(2), nullable=False)
    ZipCode = db.Column(db.String(20), nullable=False)
    EmailAddress = db.Column(db.String(100), unique=True, nullable=False)
    Password = db.Column(db.String(255), nullable=False)  # Add this field
    transactions = db.relationship('Transaction', backref='employee', lazy=True)

    def to_dict(self):
        return {
            'EmployeeID': self.EmployeeID,
            'EmployeeNumber': self.EmployeeNumber,
            'Name': f"{self.FirstName} {self.LastName}",
            'Title': self.Title,
            'EmailAddress': self.EmailAddress,
            'Location': f"{self.City}, {self.State}"
        }

class Customer(db.Model):
    __tablename__ = 'Customers'
    CustomerID = db.Column(db.Integer, primary_key=True)
    DateCreated = db.Column(db.DateTime, default=datetime.utcnow)
    AccountNumber = db.Column(db.String(50), unique=True, nullable=False)
    AccountTypeID = db.Column(db.Integer, db.ForeignKey('AccountType.AccountTypeID'), nullable=False)
    Fname = db.Column(db.String(100), nullable=False)
    Lname = db.Column(db.String(100), nullable=False)
    Gender = db.Column(db.String(10), nullable=False)
    Address = db.Column(db.String(255), nullable=False)
    City = db.Column(db.String(100), nullable=False)
    State = db.Column(db.String(2), nullable=False)
    PhoneNumber = db.Column(db.String(15), unique=True, nullable=False)
    EmailAddress = db.Column(db.String(100), unique=True, nullable=False)
    Balance = db.Column(db.Numeric(10, 2), default=0.00, nullable=False)
    
    account_type = db.relationship('AccountType', backref='customers')
    transactions = db.relationship('Transaction', backref='customer', lazy=True)

    def to_dict(self):
        return {
            'CustomerID': self.CustomerID,
            'AccountNumber': self.AccountNumber,
            'Name': f"{self.Fname} {self.Lname}",
            'AccountType': self.account_type.AccountType,
            'Gender': self.Gender,
            'Address': f"{self.Address}, {self.City}, {self.State}",
            'PhoneNumber': self.PhoneNumber,
            'EmailAddress': self.EmailAddress,
            'DateCreated': self.DateCreated.strftime('%Y-%m-%d %H:%M:%S'),
            'Balance': float(self.Balance)
        }

class Transaction(db.Model):
    __tablename__ = 'Transactions'
    TransactionID = db.Column(db.Integer, primary_key=True)
    CustomerID = db.Column(db.Integer, db.ForeignKey('Customers.CustomerID'), nullable=False)
    EmployeeID = db.Column(db.Integer, db.ForeignKey('Employees.EmployeeID'), nullable=False)  # Add this field
    TransactionType = db.Column(db.String(20), nullable=False)
    Amount = db.Column(db.Numeric(10, 2), nullable=False)
    TransactionDate = db.Column(db.DateTime, default=datetime.utcnow)
    Description = db.Column(db.String(255))

    def to_dict(self):
        return {
            'TransactionID': self.TransactionID,
            'CustomerID': self.CustomerID,
            'EmployeeID': self.EmployeeID,
            'EmployeeName': f"{self.employee.FirstName} {self.employee.LastName}",
            'TransactionType': self.TransactionType,
            'Amount': float(self.Amount),
            'TransactionDate': self.TransactionDate.strftime('%Y-%m-%d %H:%M:%S'),
            'Description': self.Description
        }

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/customers', methods=['GET'])
def get_customers():
    query = request.args.get('query', '')
    if query:
        customers = Customer.query.filter(
            (Customer.Fname.ilike(f'%{query}%')) |
            (Customer.Lname.ilike(f'%{query}%')) |
            (Customer.AccountNumber.ilike(f'%{query}%'))
        ).all()
    else:
        customers = Customer.query.all()
    return jsonify([customer.to_dict() for customer in customers])

@app.route('/api/employees', methods=['GET'])
def get_employees():
    query = request.args.get('query', '')
    if query:
        employees = Employee.query.filter(
            (Employee.FirstName.ilike(f'%{query}%')) |
            (Employee.LastName.ilike(f'%{query}%')) |
            (Employee.EmployeeNumber.ilike(f'%{query}%'))
        ).all()
    else:
        employees = Employee.query.all()
    return jsonify([{
        'EmployeeID': emp.EmployeeID,
        'EmployeeNumber': emp.EmployeeNumber,
        'Name': f"{emp.FirstName} {emp.LastName}",
        'Title': emp.Title,
        'EmailAddress': emp.EmailAddress,
        'Location': f"{emp.City}, {emp.State}"
    } for emp in employees])

@app.route('/api/login', methods=['POST'])
def login():
    print("Login attempt received")  # Debug print
    data = request.get_json()
    print(f"Received data: {data}")  # Debug print
    
    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        print("Missing credentials")  # Debug print
        return jsonify({'error': 'Missing credentials'}), 400

    employee = Employee.query.filter_by(EmailAddress=email).first()
    print(f"Found employee: {employee}")  # Debug print
    
    if employee and employee.Password == password:  # In production, use proper password hashing
        session['employee_id'] = employee.EmployeeID
        session['employee_name'] = f"{employee.FirstName} {employee.LastName}"
        print("Login successful")  # Debug print
        return jsonify({
            'message': 'Login successful',
            'employee': employee.to_dict()
        })
    
    print("Invalid credentials")  # Debug print
    return jsonify({'error': 'Invalid credentials'}), 401

@app.route('/api/logout', methods=['POST'])
def logout():
    session.clear()
    return jsonify({'message': 'Logged out successfully'})

@app.route('/api/current-user', methods=['GET'])
def get_current_user():
    if 'employee_id' in session:
        employee = Employee.query.get(session['employee_id'])
        if employee:
            return jsonify(employee.to_dict())
    return jsonify({'error': 'Not logged in'}), 401

@app.route('/api/transaction', methods=['POST'])
@login_required
def create_transaction():
    data = request.get_json()
    customer_id = data.get('customerId')
    transaction_type = data.get('type')
    amount = data.get('amount')
    description = data.get('description')

    if not all([customer_id, transaction_type, amount]):
        return jsonify({'error': 'Missing required fields'}), 400

    try:
        customer = Customer.query.get(customer_id)
        if not customer:
            return jsonify({'error': 'Customer not found'}), 404

        amount = Decimal(str(amount))
        if transaction_type == 'Withdrawal' and amount > customer.Balance:
            return jsonify({'error': 'Insufficient funds'}), 400

        # Create transaction with employee ID
        transaction = Transaction(
            CustomerID=customer_id,
            EmployeeID=session['employee_id'],  # Add the employee ID
            TransactionType=transaction_type,
            Amount=amount,
            Description=description
        )

        # Update customer balance
        if transaction_type == 'Deposit':
            customer.Balance = customer.Balance + amount
        else:  # Withdrawal
            customer.Balance = customer.Balance - amount

        db.session.add(transaction)
        db.session.commit()

        return jsonify({
            'message': 'Transaction successful',
            'transaction': transaction.to_dict(),
            'newBalance': float(customer.Balance)
        })

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@app.route('/api/transactions/<int:customer_id>', methods=['GET'])
def get_customer_transactions(customer_id):
    try:
        transactions = Transaction.query.filter_by(CustomerID=customer_id).order_by(Transaction.TransactionDate.desc()).all()
        return jsonify([t.to_dict() for t in transactions])
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/transactions/<int:customer_id>/latest', methods=['GET'])
def get_latest_transaction(customer_id):
    try:
        transaction = Transaction.query.filter_by(CustomerID=customer_id).order_by(Transaction.TransactionDate.desc()).first()
        if transaction:
            return jsonify(transaction.to_dict())
        return jsonify({'message': 'No transactions found'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True) 