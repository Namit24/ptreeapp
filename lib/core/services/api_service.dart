import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/event_model.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio) {
    // Set base URL to your ProjecTree backend
    _dio.options.baseUrl = 'https://your-projectree-domain.vercel.app/api';
    
    // Add request/response interceptors for debugging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print(obj),
    ));
  }

  // Auth endpoints
  Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/auth/login', data: data);
      return response.data;
    } catch (e) {
      print('Login error: $e');
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/auth/register', data: data);
      return response.data;
    } catch (e) {
      print('Register error: $e');
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      print('Logout error: $e');
      // Don't throw error for logout, just log it
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      return User.fromJson(response.data);
    } catch (e) {
      print('Get current user error: $e');
      throw _handleError(e);
    }
  }

  // For testing purposes, let's add a mock login method
  Future<Map<String, dynamic>> mockLogin(String email, String password) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock successful login
    if (email.isNotEmpty && password.isNotEmpty) {
      return {
        'success': true,
        'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'id': 'mock_user_id',
          'email': email,
          'name': 'Test User',
          'username': 'testuser',
          'bio': 'This is a test user account',
          'profileImage': null,
          'college': 'Test College',
          'course': 'Computer Science',
          'year': 3,
          'skills': ['Flutter', 'React', 'Node.js'],
          'interests': ['Mobile Development', 'Web Development'],
          'followersCount': 42,
          'followingCount': 38,
          'isFollowing': false,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        }
      };
    } else {
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 401,
          data: {'message': 'Invalid credentials'},
        ),
      );
    }
  }

  // User endpoints
  Future<User> getUser(String id) async {
    try {
      final response = await _dio.get('/users/$id');
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/users/profile', data: data);
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> followUser(String id) async {
    try {
      await _dio.post('/users/$id/follow');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> unfollowUser(String id) async {
    try {
      await _dio.delete('/users/$id/follow');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<User>> getSuggestedUsers() async {
    try {
      final response = await _dio.get('/users/suggested');
      return (response.data as List).map((json) => User.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Project endpoints with mock data for testing
  Future<List<Project>> getProjects(int page) async {
    try {
      // For now, return mock data
      await Future.delayed(const Duration(seconds: 1));
      return _getMockProjects();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Event>> getEvents(int page) async {
    try {
      // For now, return mock data
      await Future.delayed(const Duration(seconds: 1));
      return _getMockEvents();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Mock data methods
  List<Project> _getMockProjects() {
    return [
      Project(
        id: '1',
        title: 'AI-Powered Study Assistant',
        description: 'A mobile app that helps students organize their study materials using AI. Built with Flutter and integrated with OpenAI API.',
        images: ['https://picsum.photos/400/300?random=1'],
        tags: ['AI', 'Flutter', 'Education'],
        openForCollaboration: true,
        userId: 'user1',
        user: User(
          id: 'user1',
          email: 'alice@example.com',
          name: 'Alice Johnson',
          username: 'alice_codes',
          bio: 'CS Student | Flutter Developer',
          profileImage: 'https://picsum.photos/100/100?random=1',
          college: 'MIT',
          course: 'Computer Science',
          year: 3,
          skills: ['Flutter', 'AI', 'Python'],
          interests: ['Mobile Development', 'Machine Learning'],
          followersCount: 156,
          followingCount: 89,
          isFollowing: false,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        likesCount: 24,
        commentsCount: 8,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Project(
        id: '2',
        title: 'Campus Food Delivery App',
        description: 'Connecting students with local food vendors. Real-time tracking and group ordering features.',
        images: [
          'https://picsum.photos/400/300?random=2',
          'https://picsum.photos/400/300?random=3',
        ],
        tags: ['React Native', 'Node.js', 'MongoDB'],
        openForCollaboration: false,
        userId: 'user2',
        user: User(
          id: 'user2',
          email: 'bob@example.com',
          name: 'Bob Smith',
          username: 'bob_dev',
          bio: 'Full Stack Developer | Entrepreneur',
          profileImage: 'https://picsum.photos/100/100?random=2',
          college: 'Stanford',
          course: 'Business',
          year: 4,
          skills: ['React', 'Node.js', 'MongoDB'],
          interests: ['Entrepreneurship', 'Food Tech'],
          followersCount: 203,
          followingCount: 145,
          isFollowing: true,
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        likesCount: 67,
        commentsCount: 15,
        isLiked: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
  }

  List<Event> _getMockEvents() {
    return [
      Event(
        id: '1',
        title: 'Tech Talk: Future of AI',
        description: 'Join us for an exciting discussion about the future of artificial intelligence and its impact on various industries.',
        images: ['https://picsum.photos/400/300?random=4'],
        tags: ['AI', 'Technology', 'Future'],
        date: DateTime.now().add(const Duration(days: 7)),
        location: 'Main Auditorium, Building A',
        userId: 'user3',
        user: User(
          id: 'user3',
          email: 'carol@example.com',
          name: 'Carol Davis',
          username: 'carol_ai',
          bio: 'AI Researcher | Event Organizer',
          profileImage: 'https://picsum.photos/100/100?random=3',
          college: 'Harvard',
          course: 'Computer Science',
          year: 4,
          skills: ['AI', 'Python', 'Research'],
          interests: ['Artificial Intelligence', 'Public Speaking'],
          followersCount: 89,
          followingCount: 67,
          isFollowing: false,
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        likesCount: 45,
        commentsCount: 12,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ];
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response!.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'];
        }
        return 'Server error: ${error.response!.statusCode}';
      }
      return 'Network error: Please check your connection';
    }
    return 'An unexpected error occurred';
  }

  // Rest of the methods remain the same...
  Future<Project> getProject(String id) async {
    try {
      final response = await _dio.get('/projects/$id');
      return Project.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Project> createProject(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/projects', data: data);
      return Project.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Project> updateProject(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/projects/$id', data: data);
      return Project.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteProject(String id) async {
    try {
      await _dio.delete('/projects/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> likeProject(String id) async {
    try {
      await _dio.post('/projects/$id/like');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Event> getEvent(String id) async {
    try {
      final response = await _dio.get('/events/$id');
      return Event.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Event> createEvent(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/events', data: data);
      return Event.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> search(String query) async {
    try {
      final response = await _dio.get('/search', queryParameters: {'q': query});
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> uploadImage(MultipartFile file) async {
    try {
      final formData = FormData.fromMap({'file': file});
      final response = await _dio.post('/upload', data: formData);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
}
