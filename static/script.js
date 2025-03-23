// Global variables
let transactionModal;
let currentUser = null;

// Function to fetch and display customers
async function fetchCustomers(query = '') {
    try {
        const response = await fetch(`/api/customers?query=${encodeURIComponent(query)}`);
        const customers = await response.json();
        displayCustomers(customers);
    } catch (error) {
        console.error('Error fetching customers:', error);
        displayError('customerResults', 'Failed to fetch customers. Please try again.');
    }
}

// Function to fetch and display employees
async function fetchEmployees(query = '') {
    try {
        const response = await fetch(`/api/employees?query=${encodeURIComponent(query)}`);
        const employees = await response.json();
        displayEmployees(employees);
    } catch (error) {
        console.error('Error fetching employees:', error);
        displayError('employeeResults', 'Failed to fetch employees. Please try again.');
    }
}

// Function to display customers in the UI
function displayCustomers(customers) {
    const resultsContainer = document.getElementById('customerResults');
    resultsContainer.innerHTML = '';

    if (customers.length === 0) {
        resultsContainer.innerHTML = '<div class="text-center text-muted">No customers found</div>';
        return;
    }

    customers.forEach(customer => {
        const customerElement = document.createElement('div');
        customerElement.className = 'list-group-item record-item';
        customerElement.setAttribute('data-customer-id', customer.CustomerID);
        customerElement.innerHTML = `
            <div class="record-name">${customer.Name}</div>
            <div class="record-details">
                <div><strong>Account Number:</strong> ${customer.AccountNumber}</div>
                <div><strong>Account Type:</strong> ${customer.AccountType}</div>
                <div><strong>Gender:</strong> ${customer.Gender}</div>
                <div><strong>Address:</strong> ${customer.Address}</div>
                <div><strong>Phone:</strong> ${customer.PhoneNumber}</div>
                <div><strong>Email:</strong> ${customer.EmailAddress}</div>
                <div><strong>Member Since:</strong> ${customer.DateCreated}</div>
                <div><strong>Current Balance:</strong> <span class="balance">$${customer.Balance.toFixed(2)}</span></div>
            </div>
            <div class="transaction-section mt-3">
                <h5>Transactions</h5>
                <div class="transaction-actions mb-3">
                    <button class="btn btn-success btn-sm" onclick="showTransactionModal('${customer.CustomerID}', 'Deposit')">Make Deposit</button>
                    <button class="btn btn-danger btn-sm" onclick="showTransactionModal('${customer.CustomerID}', 'Withdrawal')">Make Withdrawal</button>
                    <button class="btn btn-info btn-sm" onclick="viewTransactionHistory('${customer.CustomerID}')">View History</button>
                </div>
                <div id="transactionHistory-${customer.CustomerID}" class="transaction-history"></div>
            </div>
        `;
        resultsContainer.appendChild(customerElement);
    });
}

// Function to display employees in the UI
function displayEmployees(employees) {
    const resultsContainer = document.getElementById('employeeResults');
    resultsContainer.innerHTML = '';

    if (employees.length === 0) {
        resultsContainer.innerHTML = '<div class="text-center text-muted">No employees found</div>';
        return;
    }

    employees.forEach(employee => {
        const employeeElement = document.createElement('div');
        employeeElement.className = 'list-group-item record-item';
        employeeElement.innerHTML = `
            <div class="record-name">${employee.Name}</div>
            <div class="record-details">
                <div><strong>Employee Number:</strong> ${employee.EmployeeNumber}</div>
                <div><strong>Title:</strong> ${employee.Title}</div>
                <div><strong>Location:</strong> ${employee.Location}</div>
                <div><strong>Email:</strong> ${employee.EmailAddress}</div>
            </div>
        `;
        resultsContainer.appendChild(employeeElement);
    });
}

// Function to display error messages
function displayError(containerId, message) {
    const resultsContainer = document.getElementById(containerId);
    resultsContainer.innerHTML = `
        <div class="alert alert-danger" role="alert">
            ${message}
        </div>
    `;
}

// Function to handle customer search
async function searchCustomers() {
    if (!currentUser) {
        alert('Please log in to search customers');
        return;
    }

    const query = document.getElementById('customerSearch').value;
    try {
        const response = await fetch(`/api/customers?query=${encodeURIComponent(query)}`);
        if (response.ok) {
            const customers = await response.json();
            displayCustomers(customers);
        } else {
            alert('Error fetching customers');
        }
    } catch (error) {
        console.error('Error:', error);
        alert('An error occurred while searching customers');
    }
}

// Function to handle employee search
async function searchEmployees() {
    if (!currentUser) {
        alert('Please log in to search employees');
        return;
    }

    const query = document.getElementById('employeeSearch').value;
    try {
        const response = await fetch(`/api/employees?query=${encodeURIComponent(query)}`);
        if (response.ok) {
            const employees = await response.json();
            displayEmployees(employees);
        } else {
            alert('Error fetching employees');
        }
    } catch (error) {
        console.error('Error:', error);
        alert('An error occurred while searching employees');
    }
}

// Add event listeners for Enter key in search inputs
document.addEventListener('DOMContentLoaded', function() {
    // Initialize transaction modal
    transactionModal = new bootstrap.Modal(document.getElementById('transactionModal'));

    // Add event listener for customer search
    const customerSearchInput = document.getElementById('customerSearch');
    if (customerSearchInput) {
        customerSearchInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                searchCustomers();
            }
        });
    }

    // Add event listener for employee search
    const employeeSearchInput = document.getElementById('employeeSearch');
    if (employeeSearchInput) {
        employeeSearchInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                searchEmployees();
            }
        });
    }

    // Add login form submit handler
    const loginForm = document.getElementById('loginForm');
    if (loginForm) {
        loginForm.addEventListener('submit', function(e) {
            e.preventDefault();
            login();
        });
    }

    // Check if user is already logged in (only once)
    checkLoginStatus();
});

// Transaction Modal Functions
function showTransactionModal(customerId, type) {
    document.getElementById('transactionCustomerId').value = customerId;
    document.getElementById('transactionType').value = type;
    document.getElementById('transactionModalTitle').textContent = `Make ${type}`;
    document.getElementById('transactionAmount').value = '';
    document.getElementById('transactionDescription').value = '';
    transactionModal.show();
}

async function submitTransaction() {
    if (!currentUser) {
        alert('Please log in to perform transactions');
        return;
    }

    const customerId = document.getElementById('transactionCustomerId').value;
    const type = document.getElementById('transactionType').value;
    const amount = document.getElementById('transactionAmount').value;
    const description = document.getElementById('transactionDescription').value;

    if (!amount || amount <= 0) {
        alert('Please enter a valid amount');
        return;
    }

    try {
        const response = await fetch('/api/transaction', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                customerId: parseInt(customerId),
                type: type,
                amount: parseFloat(amount),
                description: description
            })
        });

        const data = await response.json();

        if (response.ok) {
            // Update the customer's balance in the UI
            const customerElement = document.querySelector(`[data-customer-id="${customerId}"]`);
            if (customerElement) {
                const balanceElement = customerElement.querySelector('.balance');
                if (balanceElement) {
                    balanceElement.textContent = `$${data.newBalance.toFixed(2)}`;
                }
            }

            // Refresh transaction history
            viewTransactionHistory(customerId);
            
            // Close modal and show success message
            transactionModal.hide();
            alert('Transaction successful!');
        } else {
            alert(data.error || 'Transaction failed');
        }
    } catch (error) {
        console.error('Error:', error);
        alert('An error occurred while processing the transaction');
    }
}

async function viewTransactionHistory(customerId) {
    try {
        const response = await fetch(`/api/transactions/${customerId}`);
        const transactions = await response.json();
        
        const historyContainer = document.getElementById(`transactionHistory-${customerId}`);
        if (!historyContainer) return;

        if (transactions.length === 0) {
            historyContainer.innerHTML = '<div class="text-muted">No transactions found</div>';
            return;
        }

        const historyHTML = transactions.map(transaction => `
            <div class="transaction-item ${transaction.TransactionType.toLowerCase()}">
                <div class="transaction-header">
                    <span class="transaction-type">${transaction.TransactionType}</span>
                    <span class="transaction-date">${transaction.TransactionDate}</span>
                </div>
                <div class="transaction-amount">$${transaction.Amount.toFixed(2)}</div>
                ${transaction.Description ? `<div class="transaction-description">${transaction.Description}</div>` : ''}
            </div>
        `).join('');

        historyContainer.innerHTML = historyHTML;
    } catch (error) {
        console.error('Error:', error);
        alert('Error loading transaction history');
    }
}

// Authentication functions
async function checkLoginStatus() {
    try {
        const response = await fetch('/api/current-user');
        if (response.ok) {
            const data = await response.json();
            currentUser = data;
            updateUIForLoggedInUser(data);
        } else {
            showLoginForm();
        }
    } catch (error) {
        console.error('Error checking login status:', error);
        showLoginForm();
    }
}

async function login() {
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;

    try {
        const response = await fetch('/api/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ email, password })
        });

        const data = await response.json();

        if (response.ok) {
            currentUser = data.employee;
            updateUIForLoggedInUser(data.employee);
            // Refresh any existing data
            searchCustomers();
            searchEmployees();
        } else {
            alert(data.error || 'Login failed');
        }
    } catch (error) {
        console.error('Error:', error);
        alert('An error occurred during login');
    }
}

async function logout() {
    try {
        const response = await fetch('/api/logout', {
            method: 'POST'
        });

        if (response.ok) {
            currentUser = null;
            showLoginForm();
            clearResults();
        } else {
            alert('Logout failed');
        }
    } catch (error) {
        console.error('Error:', error);
        alert('An error occurred during logout');
    }
}

function updateUIForLoggedInUser(employee) {
    document.getElementById('loginSection').style.display = 'none';
    document.getElementById('mainContent').style.display = 'block';
    document.getElementById('userName').textContent = `Logged in as: ${employee.Name}`;
}

function showLoginForm() {
    document.getElementById('loginSection').style.display = 'block';
    document.getElementById('mainContent').style.display = 'none';
    document.getElementById('userName').textContent = '';
}

function clearResults() {
    document.getElementById('customerResults').innerHTML = '';
    document.getElementById('employeeResults').innerHTML = '';
} 