
import React from 'react';
import GenericContentManager from '@/components/dashboard/GenericContentManager';

function ContactMessagesManager() {
    const columns = [
        { key: 'name', label: 'Sender' },
        { key: 'subject', label: 'Subject' },
        { key: 'created_at', label: 'Date', type: 'date' },
        { key: 'status', label: 'Status' }
    ];
    const formFields = [
        { key: 'status', label: 'Status', type: 'select', options: [{value:'new', label:'New'},{value:'read', label:'Read'},{value:'replied', label:'Replied'}] }
    ];
    return <GenericContentManager tableName="contact_messages" resourceName="Message" columns={columns} formFields={formFields} permissionPrefix="contact_messages" />;
}
export default ContactMessagesManager;
