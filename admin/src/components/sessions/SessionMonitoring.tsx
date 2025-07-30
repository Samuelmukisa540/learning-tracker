import React, { useState, useEffect } from 'react';
import { Calendar, Clock, Filter, Download } from 'lucide-react';
import { StudySession } from '../../types';
import { format } from 'date-fns';

const SessionMonitoring: React.FC = () => {
  const [sessions, setSessions] = useState<StudySession[]>([]);
  const [dateFilter, setDateFilter] = useState('today');

  useEffect(() => {
    const mockSessions: StudySession[] = [
      {
        id: '1',
        userId: 'user1',
        courseId: 'course1',
        startTime: new Date('2024-01-21T09:00:00'),
        endTime: new Date('2024-01-21T10:30:00'),
        duration: 90,
        status: 'completed',
        notes: 'Completed React hooks chapter'
      },
      {
        id: '2',
        userId: 'user2',
        courseId: 'course2',
        startTime: new Date('2024-01-21T14:00:00'),
        endTime: new Date('2024-01-21T15:15:00'),
        duration: 75,
        status: 'completed'
      },
      {
        id: '3',
        userId: 'user3',
        courseId: 'course1',
        startTime: new Date('2024-01-21T16:00:00'),
        duration: 45,
        status: 'active'
      }
    ];
    setSessions(mockSessions);
  }, []);

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active': return 'bg-green-100 text-green-800';
      case 'paused': return 'bg-yellow-100 text-yellow-800';
      case 'completed': return 'bg-blue-100 text-blue-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const formatDuration = (minutes: number) => {
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    return hours > 0 ? `${hours}h ${mins}m` : `${mins}m`;
  };

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Study Sessions</h1>
          <p className="text-gray-600 mt-1">Monitor active and completed study sessions</p>
        </div>
        <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors flex items-center space-x-2">
          <Download className="w-4 h-4" />
          <span>Export Data</span>
        </button>
      </div>

      {/* Filters */}
      <div className="bg-white p-4 rounded-lg shadow-sm border border-gray-200">
        <div className="flex flex-col md:flex-row md:items-center md:justify-between space-y-4 md:space-y-0">
          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-2">
              <Calendar className="w-4 h-4 text-gray-400" />
              <select
                value={dateFilter}
                onChange={(e) => setDateFilter(e.target.value)}
                className="border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="today">Today</option>
                <option value="week">This Week</option>
                <option value="month">This Month</option>
                <option value="all">All Time</option>
              </select>
            </div>
            
            <div className="flex items-center space-x-2">
              <Filter className="w-4 h-4 text-gray-400" />
              <select className="border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500">
                <option value="all">All Status</option>
                <option value="active">Active</option>
                <option value="completed">Completed</option>
                <option value="paused">Paused</option>
              </select>
            </div>
          </div>
          
          <div className="text-sm text-gray-600">
            Total Sessions: {sessions.length}
          </div>
        </div>
      </div>

      {/* Sessions Table */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="text-left py-3 px-6 font-medium text-gray-900">Student</th>
                <th className="text-left py-3 px-6 font-medium text-gray-900">Course</th>
                <th className="text-left py-3 px-6 font-medium text-gray-900">Start Time</th>
                <th className="text-left py-3 px-6 font-medium text-gray-900">Duration</th>
                <th className="text-left py-3 px-6 font-medium text-gray-900">Status</th>
                <th className="text-left py-3 px-6 font-medium text-gray-900">Notes</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {sessions.map((session) => (
                <tr key={session.id} className="hover:bg-gray-50 transition-colors">
                  <td className="py-4 px-6">
                    <div className="font-medium text-gray-900">Student {session.userId}</div>
                  </td>
                  <td className="py-4 px-6">
                    <div className="font-medium text-gray-900">Course {session.courseId}</div>
                  </td>
                  <td className="py-4 px-6 text-gray-900">
                    {format(session.startTime, 'MMM dd, HH:mm')}
                  </td>
                  <td className="py-4 px-6 text-gray-900">
                    <div className="flex items-center space-x-1">
                      <Clock className="w-4 h-4 text-gray-400" />
                      <span>{formatDuration(session.duration)}</span>
                    </div>
                  </td>
                  <td className="py-4 px-6">
                    <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(session.status)}`}>
                      {session.status}
                    </span>
                  </td>
                  <td className="py-4 px-6 text-gray-600 text-sm">
                    {session.notes || '-'}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {sessions.length === 0 && (
        <div className="text-center py-12">
          <p className="text-gray-500">No study sessions found.</p>
        </div>
      )}
    </div>
  );
};

export default SessionMonitoring;