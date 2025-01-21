import { registerControllers } from 'stimulus-vite-helpers';
import { Application } from '@hotwired/stimulus';
// import '../shared/toast';
// import '../shared/modal'

const application = Application.start();

// Configure Stimulus development experience
application.debug = false;
window.Stimulus = application;

const controllers = import.meta.glob('./**/*_controller.js', { eager: true });

// Register Stimulus controllers
registerControllers(application, controllers);
