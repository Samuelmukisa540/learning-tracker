import React, { useState, useEffect } from 'react';
import { Calendar, Clock, Filter, Download } from 'lucide-react';
import { collection, getDocs, query, orderBy, where, Timestamp, doc, getDoc } from 'firebase/firestore';
import { format } from 'date-fns';
import { db } from '../../config/firebase';

interface StudySession {
  id: string;
  userId: string;
  courseId: string;
  name: string;
  startTime: Date;
  endTime?: Date;
  duration?: number;
  status: 'active' | 'paused' | 'completed';
  notes?: string;
  studentName?: string;
  courseName?: string;
}

const SessionMonitoring: React.FC = () => {
  const [sessions, setSessions] = useState<StudySession[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [dateFilter, setDateFilter] = useState('today');
  const [statusFilter, setStatusFilter] = useState('all');

  const [userNamesCache, setUserNamesCache] = useState<Map<string, string>>(new Map());
  const [courseNamesCache, setCourseNamesCache] = useState<Map<string, string>>(new Map());

  const fetchUserName = async (userId: string): Promise<string> => {
    // Check cache first
    if (userNamesCache.has(userId)) {
      return userNamesCache.get(userId)!;
    }

    try {
      const userDoc = await getDoc(doc(db, 'users', userId));
      if (userDoc.exists()) {
        const userData = userDoc.data();
        const userName = userData.name || 'Unknown User';
        
        // Update cache
        setUserNamesCache(prev => new Map(prev).set(userId, userName));
        
        return userName;
      }
    } catch (error) {
      console.error('Error fetching user name:', error);
    }
    
    const fallbackName = `User ${userId.substring(0, 8)}`;
    setUserNamesCache(prev => new Map(prev).set(userId, fallbackName));
    return fallbackName;
  };

  const fetchCourseName = async (courseId: string): Promise<string> => {
    // Check cache first
    if (courseNamesCache.has(courseId)) {
      return courseNamesCache.get(courseId)!;
    }

    try {
      const courseDoc = await getDoc(doc(db, 'courses', courseId));
      if (courseDoc.exists()) {
        const courseData = courseDoc.data();
        const courseName = courseData.name || courseData.title || 'Unknown Course';
        
        // Update cache
        setCourseNamesCache(prev => new Map(prev).set(courseId, courseName));
        
        return courseName;
      }
    } catch (error) {
      console.error('Error fetching course name:', error);
    }
    
    const fallbackName = `Course ${courseId.substring(0, 8)}`;
    setCourseNamesCache(prev => new Map(prev).set(courseId, fallbackName));
    return fallbackName;
  };

  const fetchSessions = async () => {
    try {
      setLoading(true);
      setError(null);

      let sessionsQuery = query(
        collection(db, 'study_sessions'),
        orderBy('startTime', 'desc')
      );

      // Apply date filter
      if (dateFilter !== 'all') {
        const now = new Date();
        let startDate: Date;

        switch (dateFilter) {
          case 'today':
            startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
            break;
          case 'week':
            startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
            break;
          case 'month':
            startDate = new Date(now.getFullYear(), now.getMonth(), 1);
            break;
          default:
            startDate = new Date(0);
        }

        sessionsQuery = query(
          collection(db, 'study_sessions'),
          where('startTime', '>=', Timestamp.fromDate(startDate)),
          orderBy('startTime', 'desc')
        );
      }

      const querySnapshot = await getDocs(sessionsQuery);
      const fetchedSessions: StudySession[] = [];

      querySnapshot.forEach((doc) => {
        const data = doc.data();
        const session: StudySession = {
          id: doc.id,
          userId: data.userId || '',
          courseId: data.courseId || '',
          name: data.name || '',
          startTime: data.startTime?.toDate() || new Date(),
          endTime: data.endTime?.toDate(),
          duration: data.duration || calculateDuration(data.startTime?.toDate(), data.endTime?.toDate()),
          status: determineStatus(data.startTime?.toDate(), data.endTime?.toDate()),
          notes: data.notes || '',
          studentName: 'Loading...', // Placeholder while fetching
          courseName: 'Loading...' // Placeholder while fetching
        };
        fetchedSessions.push(session);
      });

      // Apply status filter
      const filteredSessions = statusFilter === 'all' 
        ? fetchedSessions 
        : fetchedSessions.filter(session => session.status === statusFilter);

      setSessions(filteredSessions);

      // Get unique user and course IDs
      const uniqueUserIds = [...new Set(filteredSessions.map(session => session.userId))];
      const uniqueCourseIds = [...new Set(filteredSessions.map(session => session.courseId))];
      
      // Fetch user names
      const userNamePromises = uniqueUserIds.map(async (userId) => {
        const userName = await fetchUserName(userId);
        return { userId, userName };
      });

      // Fetch course names
      const courseNamePromises = uniqueCourseIds.map(async (courseId) => {
        const courseName = await fetchCourseName(courseId);
        return { courseId, courseName };
      });

      const [userNameResults, courseNameResults] = await Promise.all([
        Promise.all(userNamePromises),
        Promise.all(courseNamePromises)
      ]);

      // Update sessions with both user and course names
      setSessions(prevSessions => 
        prevSessions.map(session => {
          const userNameResult = userNameResults.find(result => result.userId === session.userId);
          const courseNameResult = courseNameResults.find(result => result.courseId === session.courseId);
          
          return {
            ...session,
            studentName: userNameResult?.userName || session.userId,
            courseName: courseNameResult?.courseName || session.courseId
          };
        })
      );

    } catch (err) {
      console.error('Error fetching sessions:', err);
      setError('Failed to fetch study sessions. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const calculateDuration = (startTime?: Date, endTime?: Date): number => {
    if (!startTime) return 0;
    if (!endTime) {
      return Math.floor((new Date().getTime() - startTime.getTime()) / (1000 * 60));
    }
    return Math.floor((endTime.getTime() - startTime.getTime()) / (1000 * 60));
  };

  const determineStatus = (startTime?: Date, endTime?: Date): 'active' | 'paused' | 'completed' => {
    if (!startTime) return 'completed';
    if (!endTime) {
      const now = new Date();
      const diffHours = (now.getTime() - startTime.getTime()) / (1000 * 60 * 60);
      return diffHours < 24 ? 'active' : 'paused';
    }
    return 'completed';
  };

  useEffect(() => {
    fetchSessions();
  }, [dateFilter, statusFilter]);

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

  const exportData = () => {
    const csvContent = [
      ['Student Name', 'Student ID', 'Course Name', 'Course ID', 'Session Name', 'Start Time', 'Duration (minutes)', 'Status', 'Notes'],
      ...sessions.map(session => [
        session.studentName || session.userId,
        session.userId,
        session.courseName || session.courseId,
        session.courseId,
        session.name,
        format(session.startTime, 'yyyy-MM-dd HH:mm:ss'),
        session.duration?.toString() || '0',
        session.status,
        session.notes || ''
      ])
    ].map(row => row.join(',')).join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `study-sessions-${format(new Date(), 'yyyy-MM-dd')}.csv`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    window.URL.revokeObjectURL(url);
  };

  if (loading) {
    return (
      <div className="p-6 space-y-6">
        <div className="flex items-center justify-center py-12">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
          <span className="ml-2 text-gray-600">Loading sessions...</span>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-6 space-y-6">
        <div className="bg-red-50 border border-red-200 rounded-lg p-4">
          <p className="text-red-700">{error}</p>
          <button
            onClick={fetchSessions}
            className="mt-2 bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 transition-colors"
          >
            Retry
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Study Sessions</h1>
          <p className="text-gray-600 mt-1">Monitor active and completed study sessions</p>
        </div>
        <button 
          onClick={exportData}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors flex items-center space-x-2"
        >
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
              <select 
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
                className="border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
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
                <th className="text-left py-3 px-6 font-medium text-gray-900">Session Name</th>
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
                    <div className="font-medium text-gray-900">
                      {session.studentName || session.userId}
                    </div>
                  </td>
                  <td className="py-4 px-6">
                    <div className="font-medium text-gray-900">
                      {session.courseName || session.courseId}
                    </div>
                  </td>
                  <td className="py-4 px-6">
                    <div className="font-medium text-gray-900">{session.name}</div>
                  </td>
                  <td className="py-4 px-6 text-gray-900">
                    {format(session.startTime, 'MMM dd, HH:mm')}
                  </td>
                  <td className="py-4 px-6 text-gray-900">
                    <div className="flex items-center space-x-1">
                      <Clock className="w-4 h-4 text-gray-400" />
                      <span>{formatDuration(session.duration || 0)}</span>
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

      {sessions.length === 0 && !loading && (
        <div className="text-center py-12">
          <p className="text-gray-500">No study sessions found for the selected filters.</p>
        </div>
      )}
    </div>
  );
};

export default SessionMonitoring;