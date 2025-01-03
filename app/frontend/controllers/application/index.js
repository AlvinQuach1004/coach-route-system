import { registerControllers } from 'stimulus-vite-helpers'
import { Application } from '@hotwired/stimulus'
import 'flatpickr/dist/flatpickr.min.css' // Import Flatpickr CSS
import flatpickr from 'flatpickr' // Import Flatpickr JavaScript

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

const controllers = import.meta.glob('./**/*_controller.js', { eager: true })

// Register Stimulus controllers
registerControllers(application, controllers)

document.addEventListener('DOMContentLoaded', function () {
  flatpickr('#datepicker', {
    dateFormat: 'd-m-Y',
    minDate: 'today',
    mode: 'single',
    static: true,
    theme: 'light',
  })
})
