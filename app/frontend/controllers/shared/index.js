import { registerControllers } from 'stimulus-vite-helpers';
import { Application } from '@hotwired/stimulus';
import { Chart } from 'chart.js/auto'
import Chartkick from 'chartkick'
import 'chartjs-adapter-date-fns'
import './toast';
import './modal';
import './add_stop';
import './profile_editor';

const application = Application.start();

// Configure Stimulus development experience
Chartkick.use(Chart)
application.debug = false;
window.Stimulus = application;

const controllers = import.meta.glob('./**/*_controller.js', { eager: true });

// Register Stimulus controllers
registerControllers(application, controllers);
