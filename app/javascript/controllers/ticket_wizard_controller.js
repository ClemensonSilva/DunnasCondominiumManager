import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "step",
    "progressBar",
    "stepLabel",
    "nextButton",
    "backButton",
    "submitButton",
    "summaryApartment",
    "summaryType",
    "summaryTitle",
    "summaryDescription",
    "summaryAttachments",
    "summaryFinishedAt",
    "summaryStatus",
    "estimatedDisplay",
    "finishedAtInput"
  ]

  static values = {
    autoCalculateFinishedAt: Boolean,
    slaMap: Object
  }

  connect() {
    this.currentStepIndex = 0
    this.boundReset = this.reset.bind(this)
    this.element.addEventListener("hidden.bs.modal", this.boundReset)
    this.showStep(0)
    this.refreshSummary()
  }

  disconnect() {
    this.element.removeEventListener("hidden.bs.modal", this.boundReset)
  }

  next(event) {
    event.preventDefault()

    if (!this.validateCurrentStep()) {
      return
    }

    if (this.currentStepIndex >= this.stepTargets.length - 1) {
      this.refreshSummary()
      return
    }

    this.showStep(this.currentStepIndex + 1)
    this.refreshSummary()
  }

  back(event) {
    event.preventDefault()

    if (this.currentStepIndex === 0) return

    this.showStep(this.currentStepIndex - 1)
  }

  submit(event) {
    if (!this.validateCurrentStep()) {
      event.preventDefault()
      return
    }

    this.refreshSummary()
  }

  showStep(index) {
    const nextIndex = Math.max(0, Math.min(index, this.stepTargets.length - 1))
    this.currentStepIndex = nextIndex

    this.stepTargets.forEach((step, stepIndex) => {
      step.classList.toggle("d-none", stepIndex !== nextIndex)
    })

    this.updateProgress()
    this.updateButtons()
  }

  updateProgress() {
    const totalSteps = this.stepTargets.length
    const currentPosition = this.currentStepIndex + 1
    const percentage = Math.round((currentPosition / totalSteps) * 100)

    if (this.hasProgressBarTarget) {
      this.progressBarTarget.style.width = `${percentage}%`
      this.progressBarTarget.textContent = `${percentage}%`
    }

    if (this.hasStepLabelTarget) {
      this.stepLabelTarget.textContent = `Etapa ${currentPosition} de ${totalSteps}`
    }
  }

  updateButtons() {
    if (this.hasBackButtonTarget) {
      this.backButtonTarget.classList.toggle("d-none", this.currentStepIndex === 0)
    }

    if (this.hasNextButtonTarget) {
      this.nextButtonTarget.classList.toggle("d-none", this.currentStepIndex === this.stepTargets.length - 1)
    }

    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.classList.toggle("d-none", this.currentStepIndex !== this.stepTargets.length - 1)
    }
  }

  validateCurrentStep() {
    const inputs = Array.from(this.stepTargets[this.currentStepIndex].querySelectorAll("input, select, textarea"))
      .filter((field) => !field.disabled)

    const firstInvalidField = inputs.find((field) => !field.checkValidity())

    if (firstInvalidField) {
      firstInvalidField.reportValidity()
      return false
    }

    return true
  }

  refreshSummary() {
    const readField = (selector, fallback = "-") => {
      const field = this.element.querySelector(selector)
      if (!field) return fallback

      if (field.tagName === "SELECT") {
        const selectedOption = field.options[field.selectedIndex]
        return selectedOption && selectedOption.text.trim() ? selectedOption.text.trim() : fallback
      }

      return field.value && field.value.trim() ? field.value.trim() : fallback
    }

    if (this.hasSummaryApartmentTarget) {
      this.summaryApartmentTarget.textContent = readField("#ticket_apartment_id")
    }

    if (this.hasSummaryTypeTarget) {
      this.summaryTypeTarget.textContent = readField("#ticket_ticket_type_id")
    }

    if (this.hasSummaryTitleTarget) {
      this.summaryTitleTarget.textContent = readField("#ticket_title")
    }

    if (this.hasSummaryDescriptionTarget) {
      this.summaryDescriptionTarget.textContent = readField("#ticket_description")
    }

    if (this.hasSummaryAttachmentsTarget) {
      this.summaryAttachmentsTarget.textContent = readField("#ticket_attachments")
    }

    const estimatedDate = this.resolveEstimatedFinishedAt()
    const estimatedDisplay = estimatedDate ? this.formatForDisplay(estimatedDate) : "-"

    if (this.autoCalculateFinishedAtValue && this.hasFinishedAtInputTarget) {
      this.finishedAtInputTarget.value = estimatedDate ? this.formatForInput(estimatedDate) : ""
    }

    if (this.hasEstimatedDisplayTarget) {
      this.estimatedDisplayTarget.value = estimatedDisplay
    }

    if (this.hasSummaryFinishedAtTarget) {
      this.summaryFinishedAtTarget.textContent = estimatedDisplay
    }

    if (this.hasSummaryStatusTarget) {
      this.summaryStatusTarget.textContent = readField("#ticket_ticket_status_id")
    }
  }

  reset() {
    this.showStep(0)
    this.refreshSummary()
  }

  resolveEstimatedFinishedAt() {
    const ticketTypeField = this.element.querySelector("#ticket_ticket_type_id")
    if (!ticketTypeField || !ticketTypeField.value) return null

    const slaHours = Number(this.slaMapValue?.[ticketTypeField.value])
    if (!Number.isFinite(slaHours) || slaHours <= 0) return null

    return new Date(Date.now() + slaHours * 60 * 60 * 1000)
  }

  formatForDisplay(date) {
    return date.toLocaleString("pt-BR", {
      dateStyle: "short",
      timeStyle: "short"
    })
  }

  formatForInput(date) {
    const localDate = new Date(date.getTime() - date.getTimezoneOffset() * 60 * 1000)
    return localDate.toISOString().slice(0, 16)
  }
}
