import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name", "apartments", "floors"]

  static values = {
    nameSource: String,
    apartmentsSource: String,
    floorsSource: String
  }

  connect() {
    this.fillSummary = this.fillSummary.bind(this)
    this.element.addEventListener("show.bs.modal", this.fillSummary)
  }

  disconnect() {
    this.element.removeEventListener("show.bs.modal", this.fillSummary)
  }

  fillSummary() {
    this.nameTarget.textContent = this.readInput(this.nameSourceValue)
    this.apartmentsTarget.textContent = this.readInput(this.apartmentsSourceValue)
    this.floorsTarget.textContent = this.readInput(this.floorsSourceValue)
  }

  readInput(id) {
    const field = document.getElementById(id)
    return field && field.value.trim() ? field.value.trim() : "-"
  }
}
