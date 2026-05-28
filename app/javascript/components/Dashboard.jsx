// app/javascript/components/Dashboard.jsx
import React, { useState, useEffect } from 'react';
import './Dashboard.css';

export default function Dashboard() {
  const [applicants, setApplicants] = useState([]);
  const [stats, setStats] = useState({});
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all');
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedApplicant, setSelectedApplicant] = useState(null);
  const [currentPage, setCurrentPage] = useState(1);

  // Fetch applicants
  useEffect(() => {
    fetchApplicants();
    fetchStats();
    const interval = setInterval(fetchApplicants, 30000);
    return () => clearInterval(interval);
  }, [filter, searchTerm, currentPage]);

  async function fetchApplicants() {
    try {
      const query = new URLSearchParams({
        status: filter === 'all' ? '' : filter,
        search: searchTerm,
        page: currentPage,
        per_page: 20
      });

      const response = await fetch(`/dashboard/applicants?${query}`);
      const data = await response.json();

      if (data.success) {
        setApplicants(data.data);
      }
    } catch (error) {
      console.error('Error fetching applicants:', error);
    } finally {
      setLoading(false);
    }
  }

  async function fetchStats() {
    try {
      const response = await fetch('/dashboard/stats');
      const data = await response.json();

      if (data.success) {
        setStats(data.data);
      }
    } catch (error) {
      console.error('Error fetching stats:', error);
    }
  }

  async function updateStatus(applicantId, newStatus) {
    try {
      const response = await fetch(`/api/v1/applicants/${applicantId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
        },
        body: JSON.stringify({ applicant: { status: newStatus } })
      });

      if (response.ok) {
        fetchApplicants();
        if (selectedApplicant?.id === applicantId) {
          setSelectedApplicant(null);
        }
      }
    } catch (error) {
      console.error('Error updating status:', error);
    }
  }

  async function deleteApplicant(applicantId) {
    if (!confirm('Are you sure? This cannot be undone.')) return;

    try {
      const response = await fetch(`/api/v1/applicants/${applicantId}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
        }
      });

      if (response.ok) {
        fetchApplicants();
        setSelectedApplicant(null);
      }
    } catch (error) {
      console.error('Error deleting applicant:', error);
    }
  }

  const filteredApplicants = applicants.filter((app) =>
    `${app.first_name} ${app.last_name}`.toLowerCase().includes(searchTerm.toLowerCase()) ||
    app.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
    app.position_of_interest?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="dashboard-container">
      <style>{`
        body { margin: 0; background: #f5f5f5; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }
      `}</style>

      {/* Header */}
      <div className="dashboard-header">
        <h1>📄 Job Applications</h1>
        <p className="dashboard-subtitle">
          Total: <strong>{stats.total || 0}</strong> | 
          Pending: <strong style={{ color: '#ff9800' }}>{stats.pending || 0}</strong> | 
          Reviewed: <strong style={{ color: '#2196f3' }}>{stats.reviewed || 0}</strong> | 
          Hired: <strong style={{ color: '#4caf50' }}>{stats.hired || 0}</strong>
        </p>
      </div>

      {/* Search & Filter */}
      <div className="controls">
        <input
          type="text"
          placeholder="Search by name, email, or position..."
          value={searchTerm}
          onChange={(e) => {
            setSearchTerm(e.target.value);
            setCurrentPage(1);
          }}
          className="search-input"
        />

        <div className="filter-buttons">
          {['all', 'pending', 'reviewed', 'rejected', 'hired'].map((status) => (
            <button
              key={status}
              onClick={() => {
                setFilter(status);
                setCurrentPage(1);
              }}
              className={`filter-btn ${filter === status ? 'active' : ''}`}
            >
              {status.charAt(0).toUpperCase() + status.slice(1)}
            </button>
          ))}
        </div>
      </div>

      {/* Loading State */}
      {loading && <div className="loading">Loading...</div>}

      {/* Table */}
      {!loading && filteredApplicants.length > 0 && !selectedApplicant && (
        <div className="table-wrapper">
          <table className="applicants-table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Position</th>
                <th>Date</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredApplicants.map((applicant) => (
                <tr key={applicant.id}>
                  <td><strong>{applicant.full_name}</strong></td>
                  <td><a href={`mailto:${applicant.email}`}>{applicant.email}</a></td>
                  <td>{applicant.position_of_interest || '-'}</td>
                  <td>{new Date(applicant.created_at).toLocaleDateString()}</td>
                  <td>
                    <select
                      value={applicant.status}
                      onChange={(e) => updateStatus(applicant.id, e.target.value)}
                      className="status-select"
                      style={{ backgroundColor: statusColor(applicant.status) }}
                    >
                      <option value="pending">Pending</option>
                      <option value="reviewed">Reviewed</option>
                      <option value="rejected">Rejected</option>
                      <option value="hired">Hired</option>
                    </select>
                  </td>
                  <td>
                    <button
                      onClick={() => setSelectedApplicant(applicant)}
                      className="view-btn"
                    >
                      View
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Detail Modal */}
      {selectedApplicant && (
        <div className="modal-overlay">
          <div className="modal">
            <div className="modal-header">
              <h2>{selectedApplicant.full_name}</h2>
              <button onClick={() => setSelectedApplicant(null)} className="close-btn">✕</button>
            </div>

            <div className="modal-content">
              <div className="detail-column">
                <div className="detail-group">
                  <label>Contact</label>
                  <p><strong>Email:</strong> {selectedApplicant.email}</p>
                  <p><strong>Phone:</strong> {selectedApplicant.phone || 'N/A'}</p>
                </div>

                <div className="detail-group">
                  <label>Job</label>
                  <p><strong>Position:</strong> {selectedApplicant.position_of_interest || 'N/A'}</p>
                  <p><strong>Experience:</strong> {selectedApplicant.years_of_experience || 'N/A'}</p>
                  <p><strong>Salary:</strong> {selectedApplicant.expected_salary || 'N/A'}</p>
                  <p><strong>Timeline:</strong> {selectedApplicant.timeline_to_start || 'N/A'}</p>
                </div>

                <div className="detail-group">
                  <label>Tech Stack</label>
                  <p>{selectedApplicant.tech_stack || 'Not provided'}</p>
                </div>

                <div className="detail-group">
                  <label>Motivation</label>
                  <p>{selectedApplicant.why_montani || 'Not provided'}</p>
                </div>

                <div className="detail-group">
                  <label>Resume</label>
                  {selectedApplicant.resume_url ? (
                    <a href={selectedApplicant.resume_url} target="_blank" rel="noopener noreferrer" className="download-btn">
                      📥 Download PDF
                    </a>
                  ) : (
                    <p>No resume</p>
                  )}
                </div>
              </div>
            </div>

            <div className="modal-actions">
              <button onClick={() => setSelectedApplicant(null)} className="btn btn-secondary">Back</button>
              <button onClick={() => deleteApplicant(selectedApplicant.id)} className="btn btn-danger">Delete</button>
            </div>
          </div>
        </div>
      )}

      {/* Empty State */}
      {!loading && filteredApplicants.length === 0 && (
        <div className="empty-state">No applications found.</div>
      )}
    </div>
  );
}

function statusColor(status) {
  const colors = {
    pending: '#fff3e0',
    reviewed: '#e3f2fd',
    rejected: '#ffebee',
    hired: '#e8f5e9'
  };
  return colors[status] || '#f5f5f5';
}
