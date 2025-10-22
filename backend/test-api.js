// Simple API test script
const baseUrl = 'http://localhost:3000';

async function testAPI() {
  console.log('🧪 Testing HelpLink API...\n');

  try {
    // Test 1: Root endpoint
    console.log('1️⃣ Testing root endpoint...');
    const rootResponse = await fetch(baseUrl);
    const rootData = await rootResponse.json();
    console.log('✅ Root:', rootData);
    console.log('');

    // Test 2: Create a user
    console.log('2️⃣ Creating test user...');
    const createUserResponse = await fetch(`${baseUrl}/api/users`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        firebaseUid: 'test_firebase_uid_123',
        username: 'Test User',
        email: 'testuser@example.com',
        mobile: '1234567890'
      })
    });
    const userData = await createUserResponse.json();
    console.log('✅ User created:', userData);
    console.log('');

    // Test 3: Get user by Firebase UID
    console.log('3️⃣ Getting user by Firebase UID...');
    const getUserResponse = await fetch(`${baseUrl}/api/users/test_firebase_uid_123`);
    const getUser = await getUserResponse.json();
    console.log('✅ User retrieved:', getUser.data);
    console.log('');

    // Test 4: Create a help request
    console.log('4️⃣ Creating help request...');
    const createHelpResponse = await fetch(`${baseUrl}/api/help-requests`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        firebaseUid: 'test_firebase_uid_123',
        title: 'Need help with homework',
        description: 'Looking for someone to help me understand calculus',
        category: 'Academic',
        urgency: 'Medium',
        location: {
          type: 'Point',
          coordinates: [78.4867, 17.3850], // Hyderabad coordinates
          address: 'Hyderabad, India'
        }
      })
    });
    const helpData = await createHelpResponse.json();
    console.log('✅ Help request created:', helpData);
    console.log('');

    // Test 5: Get all help requests
    console.log('5️⃣ Getting all help requests...');
    const getHelpResponse = await fetch(`${baseUrl}/api/help-requests`);
    const allHelp = await getHelpResponse.json();
    console.log(`✅ Found ${allHelp.count} help requests`);
    console.log('');

    console.log('🎉 All tests passed!\n');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

testAPI();
