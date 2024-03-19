// public/app.js
document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('calculator-form');
    const output = document.getElementById('calculator-output');
    const newBusinessContainer = document.getElementById('new-business-container');
    const newDebtContainer = document.getElementById('new-debt-container');

    let nextBusinessId = 1;
    let nextDebtId = 1;

    document.getElementById('add-business-btn').addEventListener('click', addNewBusinessFields);
    document.getElementById('add-debt-btn').addEventListener('click', addNewDebtFields);

    form.addEventListener('submit', function(event) {
        event.preventDefault();
        const formData = new FormData(form);
        const data = Object.fromEntries(formData);

        fetch('/calculate', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        })
        .then(response => {
            if (!response.ok) {
                console.log('Response Status:', response.status);
                response.text().then(text => console.log('Response Body:', text));
                throw new Error('Network response was not ok');
            }
            return response.json();
        })
        .then(result => {
            if (result.error) {
                output.innerHTML = `<h2>Error:</h2><p>${result.error}</p>`;
            } else {
                // Assuming `result` is an array of objects, each representing financials for a year
                let tableHTML = `<table><tr><th>Year</th><th>Income (Before Tax)</th><th>Income (After Tax)</th><th>Debt</th><th>Investments</th><th>Savings</th></tr>`;
                result.forEach(yearlyFinancials => {
                    tableHTML += `<tr>
                                    <td>${yearlyFinancials.year}</td>
                                    <td>$${yearlyFinancials.income_before_tax.toFixed(2)}</td>
                                    <td>$${yearlyFinancials.income_after_tax.toFixed(2)}</td>
                                    <td>$${yearlyFinancials.debt.toFixed(2)}</td>
                                    <td>$${yearlyFinancials.investments.toFixed(2)}</td>
                                    <td>$${yearlyFinancials.savings.toFixed(2)}</td>
                                  </tr>`;
                });
                tableHTML += `</table>`;
                output.innerHTML = tableHTML;
            }
        })
        .catch(error => {
            console.error('Error:', error);
            output.innerHTML = `<h2>Error:</h2><p>Failed to fetch calculation result.</p>`;
        });
    });

    function addNewBusinessFields() {
        const businessId = nextBusinessId++;
        const businessFields = `
            <div class="business-fields" id="business-${businessId}">
                <h3>New Business ${businessId}</h3>
                <div>
                    <label for="business-${businessId}-name">Business Name:</label>
                    <input type="text" id="business-${businessId}-name" name="business-${businessId}-name" required>
                </div>
                <div>
                    <label for="business-${businessId}-acquisition-year">Acquisition Year:</label>
                    <input type="number" id="business-${businessId}-acquisition-year" name="business-${businessId}-acquisition-year" required>
                </div>
                <div>
                    <label for="business-${businessId}-investment-amount">Investment Amount:</label>
                    <input type="number" id="business-${businessId}-investment-amount" name="business-${businessId}-investment-amount" required>
                </div>
                <div>
                    <label for="business-${businessId}-initial-income">Initial Income (before tax):</label>
                    <input type="number" id="business-${businessId}-initial-income" name="business-${businessId}-initial-income" required>
                </div>
                <div>
                    <label>Growth Rates (%):</label>
                    <div id="business-${businessId}-growth-rates-container"></div>
                    <button type="button" onclick="addGrowthRateField(${businessId})">Add Growth Rate</button>
                </div>
                <button type="button" onclick="deleteBusinessFields(${businessId})">Delete</button>
            </div>
        `;
        newBusinessContainer.insertAdjacentHTML('beforeend', businessFields);
    }

    function addNewDebtFields() {
        const debtId = nextDebtId++;
        const debtFields = `
            <div class="debt-fields" id="debt-${debtId}">
                <h3>New Debt ${debtId}</h3>
                <div>
                    <label for="debt-${debtId}-amount">Loan Amount:</label>
                    <input type="number" id="debt-${debtId}-amount" name="debt-${debtId}-amount" required>
                </div>
                <div>
                    <label for="debt-${debtId}-interest-rate">Interest Rate (%):</label>
                    <input type="number" id="debt-${debtId}-interest-rate" name="debt-${debtId}-interest-rate" required>
                </div>
                <div>
                    <label for="debt-${debtId}-repayment-period">Repayment Period (years):</label>
                    <input type="number" id="debt-${debtId}-repayment-period" name="debt-${debtId}-repayment-period" required>
                </div>
                <button type="button" onclick="deleteDebtFields(${debtId})">Delete</button>
            </div>
        `;
        newDebtContainer.insertAdjacentHTML('beforeend', debtFields);
    }

    function addGrowthRateField(businessId) {
        const growthRatesContainer = document.getElementById(`business-${businessId}-growth-rates-container`);
        const growthRateId = growthRatesContainer.querySelectorAll('input').length + 1;
        const growthRateField = `
            <div class="growth-rate-field">
                <label for="business-${businessId}-growth-rate-${growthRateId}">Year ${growthRateId}:</label>
                <input type="number" id="business-${businessId}-growth-rate-${growthRateId}" name="business-${businessId}-growth-rate-${growthRateId}">
            </div>
        `;
        growthRatesContainer.insertAdjacentHTML('beforeend', growthRateField);
    }

    function deleteBusinessFields(businessId) {
        const businessFields = document.getElementById(`business-${businessId}`);
        businessFields.remove();
    }

    function deleteDebtFields(debtId) {
        const debtFields = document.getElementById(`debt-${debtId}`);
        debtFields.remove();
    }
});
