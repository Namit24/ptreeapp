import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/project_model.dart';
import '../../../core/models/event_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/supabase_service.dart';

class FeedNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  int _currentPage = 1;
  bool _hasMore = true;

  FeedNotifier() : super(const AsyncValue.loading()) {
    loadFeed();
  }

  Future<void> loadFeed() async {
    try {
      // Try to get real data from Supabase first
      final projectsData = await SupabaseService.getProjects(limit: 10);
      final eventsData = await SupabaseService.getEvents(limit: 10);
      
      final feedItems = <Map<String, dynamic>>[];
      
      // Convert Supabase data to our models
      for (final projectData in projectsData) {
        try {
          final project = Project.fromJson(projectData);
          feedItems.add({
            'type': 'project', 
            'data': project, 
            'timestamp': project.createdAt
          });
        } catch (e) {
          print('Error parsing project: $e');
        }
      }
      
      for (final eventData in eventsData) {
        try {
          final event = Event.fromJson(eventData);
          feedItems.add({
            'type': 'event', 
            'data': event, 
            'timestamp': event.createdAt
          });
        } catch (e) {
          print('Error parsing event: $e');
        }
      }
      
      // If no real data, fall back to mock data
      if (feedItems.isEmpty) {
        print('No real data found, using mock data');
        final projects = _getMockProjects();
        final events = _getMockEvents();
        
        for (final project in projects) {
          feedItems.add({'type': 'project', 'data': project, 'timestamp': project.createdAt});
        }
        
        for (final event in events) {
          feedItems.add({'type': 'event', 'data': event, 'timestamp': event.createdAt});
        }
      }
      
      // Sort by timestamp (newest first)
      feedItems.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
      
      state = AsyncValue.data(feedItems);
      _currentPage = 1;
    } catch (error, stackTrace) {
      print('Feed loading error: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    
    try {
      _currentPage++;
      await Future.delayed(const Duration(seconds: 1));
      
      // For now, just return empty to simulate no more data
      _hasMore = false;
    } catch (error) {
      // Handle error silently for pagination
    }
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _hasMore = true;
    await loadFeed();
  }

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
        title: 'Campus Food Delivery Platform',
        description: 'Connecting students with local food vendors. Features real-time tracking, group ordering, and student discounts. Built with React Native and Node.js backend.',
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
        title: 'Tech Talk: Future of AI in Education',
        description: 'Join us for an exciting discussion about how artificial intelligence is revolutionizing education. We\'ll cover the latest trends, tools, and opportunities for students and educators.',
        images: ['https://picsum.photos/400/300?random=4'],
        tags: ['AI', 'Education', 'Tech Talk', 'Future'],
        date: DateTime.now().add(const Duration(days: 7)),
        location: 'Main Auditorium, Computer Science Building',
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
}

final feedProvider = StateNotifierProvider<FeedNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return FeedNotifier();
});
