import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]
  static values = {
    autoOpen: Boolean,
    closePath: String,
    modalId: String
  }

  connect() {
    this.boundHandleHidden = this.handleHidden.bind(this)

    const modalElement = this.findModalElement()
    if (modalElement) {
      modalElement.addEventListener("hidden.bs.modal", this.boundHandleHidden)
    }

    if (this.autoOpenValue) {
      this.open()
    }
  }

  open(event) {
    if (event) event.preventDefault()

    const modalElement = this.findModalElement(event)
    if (!modalElement || !window.bootstrap) return

    window.bootstrap.Modal.getOrCreateInstance(modalElement).show()
  }

  disconnect() {
    const modalElement = this.findModalElement()
    if (modalElement && this.boundHandleHidden) {
      modalElement.removeEventListener("hidden.bs.modal", this.boundHandleHidden)
    }

    if (modalElement && window.bootstrap) {
      const modalInstance = window.bootstrap.Modal.getInstance(modalElement)
      if (modalInstance) {
        modalInstance.hide()
        modalInstance.dispose()
      }
    }
  }

  close(event) {
    if (event) event.preventDefault()

    const modalElement = this.findModalElement(event)
    if (!modalElement || !window.bootstrap) return

    window.bootstrap.Modal.getOrCreateInstance(modalElement).hide()
  }

  handleHidden() {
    if (!this.hasClosePathValue) return

    if (window.Turbo?.visit) {
      window.Turbo.visit(this.closePathValue, { action: "replace" })
      return
    }

    window.location.assign(this.closePathValue)
  }

  findModalElement(event) {
    if (this.hasModalTarget) return this.modalTarget

    const modalIdFromEvent = event?.params?.id
    if (modalIdFromEvent) return document.getElementById(modalIdFromEvent)

    if (this.hasModalIdValue) return document.getElementById(this.modalIdValue)

    return this.element.classList.contains("modal") ? this.element : null
  }
}