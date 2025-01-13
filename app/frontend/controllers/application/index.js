import { registerControllers } from 'stimulus-vite-helpers';
import { Application } from '@hotwired/stimulus';
import 'flatpickr/dist/flatpickr.min.css';
import flatpickr from 'flatpickr';

const application = Application.start();

// Configure Stimulus development experience
application.debug = false;
window.Stimulus = application;

const controllers = import.meta.glob('./**/*_controller.js', { eager: true });

// Register Stimulus controllers
registerControllers(application, controllers);
