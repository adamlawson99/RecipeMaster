import {Controller} from "@hotwired/stimulus"
import {Turbo} from "@hotwired/turbo-rails"

export default class extends Controller {
    connect() {
        document.addEventListener("turbo:before-fetch-response", (event) => {
            if (event.detail.fetchResponse.redirected) {
                event.preventDefault()
                Turbo.visit(event.detail.fetchResponse.response.url)
            }
        })
    }

    hideUrlSubmitForm() {
        const element = document.querySelector('.new-recipe-url-input');
        element.style.display = 'none';

        const loadingSpinner = document.querySelector('.loading-dots');
        loadingSpinner.style.display = 'block';
    }
}