import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["target", "template"]

    connect() {
        console.log("Nested form controller connected")
    }

    add(event) {
        if (event) event.preventDefault()

        if (!this.hasTemplateTarget || !this.hasTargetTarget) {
            console.error("Nested form targets missing")
            return
        }

        const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
        this.targetTarget.insertAdjacentHTML("beforeend", content)
    }

    remove(event) {
        if (event) event.preventDefault()

        if (!confirm("Are you sure you want to remove this part?")) return

        // Use currentTarget to always get the button that has the action
        const button = event.currentTarget
        const wrapper = button.closest(".nested-fields")

        if (!wrapper) {
            console.error("Nested fields wrapper not found")
            return
        }

        if (wrapper.dataset.newRecord === "true") {
            wrapper.remove()
        } else {
            const destroyInput = wrapper.querySelector("input[name*='_destroy']")
            if (destroyInput) destroyInput.value = "1"
            wrapper.style.display = "none"
        }
    }
}
