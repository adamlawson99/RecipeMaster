import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    selectedCategories = new Set();
    selectedTags = new Set();
    static values = {recipes: String}
    static targets = ["categoryCheckbox", "tagCheckbox"]

    connect() {
        this.createRecipeTable()
        this.setTagsAndCategories()
    }

    setTagsAndCategories() {
        this.categoryCheckboxTargets
            .filter(checkbox => checkbox.checked)
            .forEach(checkbox => {
                const category = checkbox.dataset.categoryValue.trim()
                this.selectedCategories.add(category)
            });

        this.tagCheckboxTargets
            .filter(checkbox => checkbox.checked)
            .forEach(checkbox => {
                const tag = checkbox.dataset.tagValue.trim()
                this.selectedTags.add(tag)
            });
    }

    selectCategory(event) {
        const checkbox = event.currentTarget
        const category = checkbox.dataset.categoryValue.trim()

        if (checkbox.checked) {
            this.selectedCategories.add(category)
        } else {
            this.selectedCategories.delete(category)
        }
        this.reloadTable()
    }

    selectTag() {
        const checkbox = event.currentTarget
        const tag = checkbox.dataset.tagValue.trim()

        if (checkbox.checked) {
            this.selectedTags.add(tag)
        } else {
            this.selectedTags.delete(tag)
        }
        this.reloadTable()
    }

    /**
     * Creates a recipe table from an array of recipe objects
     * @param {Array} recipes - Array of recipe objects with properties: title, description, categories, tags
     * @param {HTMLElement} container - DOM element to append the table to
     */
    reloadTable() {
        const table = document.querySelector("table")
        table.remove()
        this.createRecipeTable()
    }

    getFilteredTableData() {
        const recipes_object = JSON.parse(this.recipesValue)
        return recipes_object.filter(recipe => {
            const categories = recipe["categories"]?.split(",") ?? []
            const tags = recipe["tags"]?.split(",") ?? []

            return (this.selectedTags.size === 0 && this.selectedCategories.size === 0) ||
                this.doRecipesCategoriesIncludeSelectedCategories(categories) ||
                this.doRecipesTagsIncludeSelectedTags(tags)
        })
    }

    resetFilters() {
        this.selectedCategories = new Set();
        this.selectedTags = new Set();
        this.categoryCheckboxTargets
            .forEach(checkbox => {
                checkbox.checked = false
            });

        this.tagCheckboxTargets
            .forEach(checkbox => {
                checkbox.checked = false
            });
        this.reloadTable();
    }

    doRecipesCategoriesIncludeSelectedCategories(recipe_categories) {
        return recipe_categories.some(category => {
            return this.selectedCategories.has(category.trim())
        })
    }

    doRecipesTagsIncludeSelectedTags(recipe_tags) {
        return recipe_tags.some(tag => {
            return this.selectedTags.has(tag.trim())
        })
    }

    createRecipeTable() {
        const filteredRecipes = this.getFilteredTableData()
        console.log("FILTERED RECIPES: " + filteredRecipes)
        const container = document.querySelector("#recipes-table")

        // Create table
        const table = document.createElement('table');
        table.className = 'table bt-5';

        // Create table header
        const thead = document.createElement('thead');
        const headerRow = document.createElement('tr');

        const headers = ['Recipe', 'Description', 'Categories', 'Tags', ''];
        headers.forEach(headerText => {
            const th = document.createElement('th');
            th.textContent = headerText;
            headerRow.appendChild(th);
        });

        thead.appendChild(headerRow);
        table.appendChild(thead);

        // Create table body
        const tbody = document.createElement('tbody');

        // Add rows for each recipe
        filteredRecipes.forEach(recipe => {
            const row = document.createElement('tr');

            // Add cells for each property
            const titleCell = document.createElement('td');
            titleCell.textContent = recipe.title;
            row.appendChild(titleCell);

            const descriptionCell = document.createElement('td');
            descriptionCell.textContent = recipe.description;
            row.appendChild(descriptionCell);

            const categoriesCell = document.createElement('td');
            categoriesCell.textContent = recipe.categories;
            row.appendChild(categoriesCell);

            const tagsCell = document.createElement('td');
            tagsCell.textContent = recipe.tags;
            row.appendChild(tagsCell);

            // Add view recipe button
            const actionCell = document.createElement('td');
            const viewButton = document.createElement('a');
            viewButton.href = `/recipes/${recipe.id}`;
            viewButton.className = 'btn btn-primary whitespace-nowrap';
            viewButton.textContent = 'View Recipe';
            actionCell.appendChild(viewButton);
            row.appendChild(actionCell);

            tbody.appendChild(row);
        });
        table.appendChild(tbody)

        // Add the table to the container
        container.appendChild(table);
    }
}