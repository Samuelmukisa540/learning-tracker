import React, { useState, useEffect } from 'react';
import { BookOpen, Clock, Edit, Eye, LogOut, Plus, Trash2, Users } from 'react-feather';

// Mock Firebase - In real implementation, replace with actual Firebase SDK
const mockFirebase = {
  auth: {
    currentUser: { uid: 'admin123', email: 'admin@school.edu' },
    signOut: () => Promise.resolve(),
  },
  firestore: {
    collection: (name) => ({
      get: () => Promise.resolve({
        docs: name === 'users' ? mockUsers.map(u => ({ id: u.id, data: () => u })) :
              name === 'courses' ? mockCourses.map(c => ({ id: c.id, data: () => c })) :
              name === 'study_sessions' ? mockSessions.map(s => ({ id: s.id, data: () => s })) : []
      }),
      add: (data) => Promise.resolve({ id: Date.now().toString() }),
      doc: (id) => ({
        update: (data) => Promise.resolve(),
        delete: () => Promise.resolve(),
      })
    })
  }
};

// Mock data
const mockUsers = [
  { id: '1', name: 'Alice Johnson', email: 'alice@student.edu', totalStudyTime: 7200, createdAt: new Date('2024-01-15') },
  { id: '2', name: 'Bob Smith', email: 'bob@student.edu', totalStudyTime: 5400, createdAt: new Date('2024-01-20') },
  { id: '3', name: 'Carol Davis', email: 'carol@student.edu', totalStudyTime: 9000, createdAt: new Date('2024-01-10') },
];

const mockCourses = [
  { id: '1', name: 'Mathematics', description: 'Advanced Mathematics Course', createdAt: new Date('2024-01-01') },
  { id: '2', name: 'Physics', description: 'Introduction to Physics', createdAt: new Date('2024-01-01') },
  { id: '3', name: 'Chemistry', description: 'Organic Chemistry Basics', createdAt: new Date('2024-01-01') },
];

const mockSessions = [
  { id: '1', userId: '1', courseId: '1', courseName: 'Mathematics', duration: 3600, startTime: new Date('2024-01-25') },
  { id: '2', userId: '2', courseId: '1', courseName: 'Mathematics', duration: 2700, startTime: new Date('2024-01-24') },
  { id: '3', userId: '1', courseId: '2', courseName: 'Physics', duration: 3600, startTime: new Date('2024-01-23') },
];

const LearningTrackerAdmin = () => {
  const [currentView, setCurrentView] = useState('dashboard');
  const [users, setUsers] = useState<Array<{ id: string; name: string; email: string; totalStudyTime: number; createdAt: Date }>>([]);
  const [courses, setCourses] = useState<Array<{ id: string; name: string; description: string; createdAt: Date }>>([]);
  const [sessions, setSessions] = useState<Array<{ id: string; userId: string; courseId: string; courseName: string; duration: number; startTime: Date }>>([]);
  const [loading, setLoading] = useState(true);

  // Modals
  const [showCourseModal, setShowCourseModal] = useState(false);
  const [editingCourse, setEditingCourse] = useState<{ id: string; name: string; description: string; createdAt: Date } | null>(null);
  const [courseForm, setCourseForm] = useState({ name: '', description: '' });

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    setLoading(true);
    try {
      const [usersSnap, coursesSnap, sessionsSnap] = await Promise.all([
        mockFirebase.firestore.collection('users').get(),
        mockFirebase.firestore.collection('courses').get(),
        mockFirebase.firestore.collection('study_sessions').get(),
      ]);

      setUsers(usersSnap.docs.map(doc => ({ id: doc.id, ...doc.data() })));
      setCourses(coursesSnap.docs.map(doc => ({ id: doc.id, ...doc.data() })));
      setSessions(sessionsSnap.docs.map(doc => ({ id: doc.id, ...doc.data() })));
    } catch (error) {
      console.error('Error loading data:', error);
    }
    setLoading(false);
  };

  const handleSaveCourse = async () => {
    try {
      if (editingCourse) {
        await mockFirebase.firestore.collection('courses').doc(editingCourse.id).update(courseForm);
        setCourses(courses.map(c => c.id === editingCourse.id ? { ...c, ...courseForm } : c));
      } else {
        const docRef = await mockFirebase.firestore.collection('courses').add({
          ...courseForm,
          createdAt: new Date(),
        });
        setCourses([...courses, { id: docRef.id, ...courseForm, createdAt: new Date() }]);
      }
      setShowCourseModal(false);
      setEditingCourse(null);
      setCourseForm({ name: '', description: '' });
    } catch (error) {
      console.error('Error saving course:', error);
    }
  };

  const handleDeleteCourse = async (courseId) => {
    if (window.confirm('Are you sure you want to delete this course?')) {
      try {
        await mockFirebase.firestore.collection('courses').doc(courseId).delete();
        setCourses(courses.filter(c => c.id !== courseId));
      } catch (error) {
        console.error('Error deleting course:', error);
      }
    }
  };

  const openEditCourse = (course) => {
    setEditingCourse(course);
    setCourseForm({ name: course.name, description: course.description });
    setShowCourseModal(true);
  };

  const getTotalStudyTime = () => {
    return sessions.reduce((total, session) => total + (session.duration || 0), 0);
  };

  const getActiveUsers = () => {
    const activeUserIds = new Set(sessions.map(s => s.userId));
    return activeUserIds.size;
  };

  const formatTime = (seconds) => {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    return `${hours}h ${minutes}m`;
  };

  const formatDate = (date) => {
    return new Date(date).toLocaleDateString();
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading dashboard...</p>
        </div>
      </div>
    );
    
}

return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-4">
            <div className="flex items-center">
              <BookOpen className="h-8 w-8 text-blue-600 mr-3" />
              <h1 className="text-2xl font-bold text-gray-900">Learning Tracker Admin</h1>
            </div>
            <button 
              onClick={() => mockFirebase.auth.signOut()}
              className="flex items-center px-4 py-2 text-sm text-gray-700 hover:text-gray-900"
            >
              <LogOut className="h-4 w-4 mr-2" />
              Logout
            </button>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Navigation */}
        <nav className="flex space-x-8 mb-8">
          {[
            { id: 'dashboard', label: 'Dashboard', icon: Eye },
            { id: 'students', label: 'Students', icon: Users },
            { id: 'courses', label: 'Courses', icon: BookOpen },
            { id: 'sessions', label: 'Study Sessions', icon: Clock },
          ].map(({ id, label, icon: Icon }) => (
            <button
              key={id}
              onClick={() => setCurrentView(id)}
              className={`flex items-center px-4 py-2 rounded-lg font-medium transition-colors ${
                currentView === id
                  ? 'bg-blue-100 text-blue-700'
                  : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'
              }`}
            >
              <Icon className="h-5 w-5 mr-2" />
              {label}
            </button>
          ))}
        </nav>

        {/* Dashboard View */}
        {currentView === 'dashboard' && (
          <div>
            <h2 className="text-3xl font-bold text-gray-900 mb-8">Dashboard Overview</h2>
            
            {/* Stats Cards */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
              <div className="bg-white rounded-lg shadow p-6">
                <div className="flex items-center">
                  <Users className="h-8 w-8 text-blue-600" />
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">Total Students</p>
                    <p className="text-2xl font-semibold text-gray-900">{users.length}</p>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-lg shadow p-6">
                <div className="flex items-center">
                  <BookOpen className="h-8 w-8 text-green-600" />
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">Active Courses</p>
                    <p className="text-2xl font-semibold text-gray-900">{courses.length}</p>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-lg shadow p-6">
                <div className="flex items-center">
                  <Clock className="h-8 w-8 text-purple-600" />
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">Total Study Time</p>
                    <p className="text-2xl font-semibold text-gray-900">{formatTime(getTotalStudyTime())}</p>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-lg shadow p-6">
                <div className="flex items-center">
                  <Users className="h-8 w-8 text-orange-600" />
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">Active Students</p>
                    <p className="text-2xl font-semibold text-gray-900">{getActiveUsers()}</p>
                  </div>
                </div>
              </div>
            </div>

            {/* Recent Activity */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
              <div className="bg-white rounded-lg shadow">
                <div className="px-6 py-4 border-b border-gray-200">
                  <h3 className="text-lg font-medium text-gray-900">Recent Study Sessions</h3>
                </div>
                <div className="divide-y divide-gray-200">
                  {sessions.slice(0, 5).map((session) => {
                    const user = users.find(u => u.id === session.userId);
                    return (
                      <div key={session.id} className="px-6 py-4">
                        <div className="flex items-center justify-between">
                          <div>
                            <p className="text-sm font-medium text-gray-900">{user?.name || 'Unknown'}</p>
                            <p className="text-sm text-gray-600">{session.courseName}</p>
                          </div>
                          <div className="text-right">
                            <p className="text-sm font-medium text-gray-900">{formatTime(session.duration)}</p>
                            <p className="text-sm text-gray-600">{formatDate(session.startTime)}</p>
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>

              <div className="bg-white rounded-lg shadow">
                <div className="px-6 py-4 border-b border-gray-200">
                  <h3 className="text-lg font-medium text-gray-900">Top Students</h3>
                </div>
                <div className="divide-y divide-gray-200">
                  {users
                    .sort((a, b) => (b.totalStudyTime || 0) - (a.totalStudyTime || 0))
                    .slice(0, 5)
                    .map((user) => (
                      <div key={user.id} className="px-6 py-4">
                        <div className="flex items-center justify-between">
                          <div>
                            <p className="text-sm font-medium text-gray-900">{user.name}</p>
                            <p className="text-sm text-gray-600">{user.email}</p>
                          </div>
                          <p className="text-sm font-medium text-blue-600">{formatTime(user.totalStudyTime || 0)}</p>
                        </div>
                      </div>
                    ))}
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Students View */}
        {currentView === 'students' && (
          <div>
            <h2 className="text-3xl font-bold text-gray-900 mb-8">Students</h2>
            
            <div className="bg-white shadow rounded-lg overflow-hidden">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Student</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Total Study Time</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Joined</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {users.map((user) => (
                    <tr key={user.id}>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          <div className="h-10 w-10 rounded-full bg-blue-100 flex items-center justify-center">
                            <span className="text-sm font-medium text-blue-800">{user.name[0]}</span>
                          </div>
                          <div className="ml-4">
                            <div className="text-sm font-medium text-gray-900">{user.name}</div>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{user.email}</td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{formatTime(user.totalStudyTime || 0)}</td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{formatDate(user.createdAt)}</td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <button className="text-blue-600 hover:text-blue-900">
                          <Eye className="h-4 w-4" />
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* Courses View */}
        {currentView === 'courses' && (
          <div>
            <div className="flex justify-between items-center mb-8">
              <h2 className="text-3xl font-bold text-gray-900">Courses</h2>
              <button
                onClick={() => {
                  setCourseForm({ name: '', description: '' });
                  setEditingCourse(null);
                  setShowCourseModal(true);
                }}
                className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center"
              >
                <Plus className="h-4 w-4 mr-2" />
                Add Course
              </button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {courses.map((course) => (
                <div key={course.id} className="bg-white rounded-lg shadow p-6">
                  <div className="flex justify-between items-start mb-4">
                    <h3 className="text-lg font-semibold text-gray-900">{course.name}</h3>
                    <div className="flex space-x-2">
                      <button
                        onClick={() => openEditCourse(course)}
                        className="text-gray-400 hover:text-blue-600"
                      >
                        <Edit className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => handleDeleteCourse(course.id)}
                        className="text-gray-400 hover:text-red-600"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </div>
                  </div>
                  <p className="text-gray-600 mb-4">{course.description}</p>
                  <div className="text-sm text-gray-500">
                    <p>Created: {formatDate(course.createdAt)}</p>
                    <p>Students: {sessions.filter(s => s.courseId === course.id).length}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Study Sessions View */}
        {currentView === 'sessions' && (
          <div>
            <h2 className="text-3xl font-bold text-gray-900 mb-8">Study Sessions</h2>
            
            <div className="bg-white shadow rounded-lg overflow-hidden">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Student</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Course</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Duration</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {sessions
                    .sort((a, b) => new Date(b.startTime).getTime() - new Date(a.startTime).getTime())
                    .map((session) => {
                      const user = users.find(u => u.id === session.userId);
                      return (
                        <tr key={session.id}>
                          <td className="px-6 py-4 whitespace-nowrap">
                            <div className="flex items-center">
                              <div className="h-8 w-8 rounded-full bg-blue-100 flex items-center justify-center">
                                <span className="text-xs font-medium text-blue-800">{user?.name[0] || 'U'}</span>
                              </div>
                              <div className="ml-3">
                                <div className="text-sm font-medium text-gray-900">{user?.name || 'Unknown'}</div>
                              </div>
                            </div>
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{session.courseName}</td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{formatTime(session.duration)}</td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{formatDate(session.startTime)}</td>
                        </tr>
                      );
                    })}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </div>

      {/* Course Modal */}
      {showCourseModal && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
            <div className="mt-3">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                {editingCourse ? 'Edit Course' : 'Add New Course'}
              </h3>
              
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Course Name</label>
                  <input
                    type="text"
                    value={courseForm.name}
                    onChange={(e) => setCourseForm({ ...courseForm, name: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="Enter course name"
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                  <textarea
                    value={courseForm.description}
                    onChange={(e) => setCourseForm({ ...courseForm, description: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="Enter course description"
                    rows={3}
                  />
                </div>
              </div>
              
              <div className="flex justify-end space-x-3 mt-6">
                <button
                  onClick={() => setShowCourseModal(false)}
                  className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300"
                >
                  Cancel
                </button>
                <button
                  onClick={handleSaveCourse}
                  className="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700"
                  disabled={!courseForm.name.trim()}
                >
                  {editingCourse ? 'Update' : 'Create'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
  }

  

  export default LearningTrackerAdmin;