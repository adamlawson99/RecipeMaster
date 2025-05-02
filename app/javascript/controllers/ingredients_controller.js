import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["template", "container"]

    connect() {
        // Make sure there's at least one row
        if (document.querySelectorAll('.ingredient-row').length === 0) {
            this.add()
        }
        const loadingSpinner = document.querySelector('.loading-dots');
        loadingSpinner.style.display = 'none';
    }

    add() {
        const tbody = document.getElementById('ingredients-tbody');
        const newRow = document.createElement('tr');
        newRow.className = 'ingredient-row';
        newRow.innerHTML = `
      <td>
        <input type="text" name="ingredients[][ingredient]" class="ingredient-name">
      </td>
      <td>
        <input type="number" name="ingredients[][quantity]" step="0.01" class="ingredient-quantity">
      </td>
      <td>
        <input type="text" name="ingredients[][measurement]" class="ingredient-measurement">
      </td>
      <td>
        <button type="button" class="btn btn-error" data-action="click->ingredients#remove">Remove</button>
      </td>
    `;
        tbody.appendChild(newRow);
    }

    remove(event) {
        const row = event.target.closest('.ingredient-row')
        console.log("ROW: " + row)
        row.remove()

        // Make sure we always have at least one row
        if (document.querySelectorAll('.ingredient-row').length === 0) {
            this.add()
        }
    }
}