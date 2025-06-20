import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/event_model.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio) {
    // Remove the backend URL since we're using Supabase directly
    // _dio.options.baseUrl = 'https://your-projectree-domain.vercel.app/api';

    // Add request/response interceptors for debugging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print(obj),
    ));
  }

  // Remove all backend API calls since we're using Supabase directly
  // The auth, projects, and events are now handled by SupabaseService

  // For testing purposes, let's add a mock login method (not used anymore)
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

  // Mock data methods for testing (these return the same data as before)
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
}
