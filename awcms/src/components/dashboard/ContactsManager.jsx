
import React from 'react';
import GenericContentManager from '@/components/dashboard/GenericContentManager';

function ContactsManager() {
  const columns = [
    { key: 'name', label: 'Location Name' },
    { key: 'city', label: 'City' },
    { key: 'phone', label: 'Phone' },
    { key: 'email', label: 'Email' }
  ];

  const formFields = [
    { key: 'name', label: 'Location Name', required: true, description: 'e.g. Head Office' },
    { key: 'address', label: 'Address', type: 'textarea', required: true },
    { key: 'city', label: 'City', required: true },
    { key: 'province', label: 'Province/State' },
    { key: 'postal_code', label: 'Postal Code' },
    { key: 'country', label: 'Country', defaultValue: 'Indonesia' },
    { key: 'phone', label: 'Phone Number' },
    { key: 'email', label: 'Email Address' },
    { key: 'latitude', label: 'Latitude', type: 'number', description: 'e.g. -6.2088' },
    { key: 'longitude', label: 'Longitude', type: 'number', description: 'e.g. 106.8456' },
    { key: 'website', label: 'Website URL' },
    { key: 'description', label: 'Description/Notes', type: 'textarea' },
    { key: 'tags', label: 'Tags', type: 'tags' }
  ];

  return (
    <GenericContentManager
      tableName="contacts"
      resourceName="Location"
      columns={columns}
      formFields={formFields}
      permissionPrefix="contacts"
    />
  );
}

export default ContactsManager;
