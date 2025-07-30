import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: "AIzaSyDbv_DIfcI0b_cslw7dGzaXMjdVgZ-X6zQ",
  authDomain: "taskmanager-66988.firebaseapp.com",
  projectId: "taskmanager-66988",
  storageBucket: "taskmanager-66988.firebasestorage.app",
  messagingSenderId: "521520084323",
  appId: "1:521520084323:web:a4c13bc852e03866d0cf56",
  measurementId: "G-1CKKR4VDQJ"
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);



export default app;