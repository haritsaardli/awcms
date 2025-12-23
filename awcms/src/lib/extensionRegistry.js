
// This registry maps database string keys to actual React components.
// It acts as the bridge between dynamic DB data and static React code.

import React from 'react';

// Import Extension Entry Points
import BackupManager from '@/extensions/backup/BackupManager';
import BackupScheduler from '@/extensions/backup/BackupScheduler';
import BackupSettings from '@/extensions/backup/BackupSettings';
import * as HelloWorld from '@/extensions/helloworld/HelloWorld.jsx';

// Registry Object
const EXTENSION_COMPONENT_MAP = {
  // Backup Extension Components
  'BackupManager': BackupManager,
  'BackupScheduler': BackupScheduler,
  'BackupSettings': BackupSettings,

  // Future extensions can be added here
  'AnalyticsDashboard': () => React.createElement('div', { className: "p-8 text-center" }, "Analytics Module Placeholder"),
  'NewsletterBuilder': () => React.createElement('div', { className: "p-8 text-center" }, "Newsletter Module Placeholder"),
  'HelloWorld': HelloWorld,
};

export const getExtensionComponent = (key) => {
  return EXTENSION_COMPONENT_MAP[key] || (() => React.createElement('div', { className: "p-4 text-red-500" }, `Component "${key}" not found in registry.`));
};

export const getAvailableComponents = () => Object.keys(EXTENSION_COMPONENT_MAP);
