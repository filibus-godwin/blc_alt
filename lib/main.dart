import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:local_auth_android/local_auth_android.dart';
import 'package:voting_app/state.dart';
import 'package:voting_app/success_page.dart';
// import 'package:local_auth_android/local_auth_android.dart';
// ···

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  authenticate();
  runApp(const ProviderScope(child: MyApp()));
}

final LocalAuthentication auth = LocalAuthentication();

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const VotingPage()),
    GoRoute(path: '/success', builder: (context, state) => const SuccessPage()),
  ],
);

authenticate() async {
  final bool _ = await auth.authenticate(
    localizedReason: 'Please authenticate to use this application',
    authMessages: const <AuthMessages>[
      AndroidAuthMessages(
        signInTitle:
            'Biometric authentication required, You must authenticate before you can use this application.',
        cancelButton: 'No thanks',
      ),
    ],
  );
}

class MyApp extends HookWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
    );
  }
}

class VotingPage extends ConsumerStatefulWidget {
  const VotingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VotingPageState();
}

class _VotingPageState extends ConsumerState<VotingPage> {
  @override
  Widget build(BuildContext context) {
    final candidates = ref.watch(candiatesProvider);
    final selectedId = ValueNotifier('');

    changeId(String id) {
      selectedId.value = id;
    }

    return ValueListenableBuilder(
      valueListenable: selectedId,
      builder: (context, s, _) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: const Text('Secure Voting Application'),
            actions: [
              FittedBox(
                child: ElevatedButton(
                  onPressed: selectedId.value.isEmpty
                      ? null
                      : () => vote(selectedId.value)
                          .then((value) => context.go('/success')),
                  child: const Text("Submit"),
                ),
              )
            ],
          ),
          body: FutureBuilder(
            future: futureInit(),
            builder: (context, res) {
              if (res.hasData) {
                if (res.data is Voted) const SuccessPage();
                return _buildOne(candidates, selectedId, changeId)!;
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        );
      },
    );
  }

  Widget? _buildOne(AsyncValue<List<Candidate>?> candidats,
      ValueNotifier<String> selectedId, dynamic changeId) {
    return candidats.when(
      data: (data) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return VotingCard(
                    imageUrl: data?[index].candidateImageUrl ?? "",
                    name: data?[index].candidateName ?? " ",
                    party: data?[index].partyName ?? "",
                    selected: selectedId.value == data?[index].partyId,
                    onClick: () => changeId(data?[index].partyId ?? ""),
                  );
                },
                childCount: data?.length,
              ),
            ),
          ],
        );
      },
      error: (_, stackTrace) {
        context.go('/success');
        return;
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class VotingCard extends HookWidget {
  const VotingCard({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.party,
    required this.onClick,
    required this.selected,
  }) : super(key: key);

  final String imageUrl;
  final String name;
  final String party;
  final bool selected;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        color: selected ? Colors.green.withOpacity(0.3) : null,
        child: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      party,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClick,
                icon: Icon(
                  Icons.fingerprint,
                  color: selected ? Colors.green : null,
                ),
                iconSize: 80,
              ),
              const SizedBox(height: 40),
              const Divider(thickness: 20, height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
