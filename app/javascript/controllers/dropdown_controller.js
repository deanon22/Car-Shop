import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["menu"]

    connect() {
        console.log("Dropdown controller connected to:", this.element)
    }

    toggle(event) {
        console.log("Toggle clicked")
        event.preventDefault()
        event.stopPropagation()
        this.menuTarget.classList.toggle("hidden")
        console.log("Menu hidden class:", this.menuTarget.classList.contains("hidden"))
    }

    hide(event) {
        if (this.element.contains(event.target)) return
        this.menuTarget.classList.add("hidden")
    }
}
