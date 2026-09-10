import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

import 'models.dart';
import 'services.dart';

class ArcadeTab extends StatefulWidget {
  const ArcadeTab({super.key});

  @override
  State<ArcadeTab> createState() => _ArcadeTabState();
}

class _ArcadeTabState extends State<ArcadeTab> {
  void _startGame(BuildContext context, TournamentItem tournament, VoidCallback gameLauncher) {
    final user = globalActiveUserNotifier.value;
    if (user == null) {
      showLoginOrRegisterDialog(context, () {
        _checkParticipationAndPlay(context, tournament, gameLauncher);
      });
    } else {
      _checkParticipationAndPlay(context, tournament, gameLauncher);
    }
  }

  void _checkParticipationAndPlay(BuildContext context, TournamentItem tournament, VoidCallback gameLauncher) {
    final user = globalActiveUserNotifier.value;
    if (user == null) return;

    // Contar cuántas veces ha participado el usuario actual en este torneo
    int userAttempts = tournament.scores.where((s) => s.playerName.toLowerCase() == user.name.toLowerCase()).length;

    if (userAttempts >= 2) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¡Oportunidades Agotadas! 🛑', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD85A7F))),
          content: Text('Hola ${user.name}, ya has participado 2 veces en este torneo y has cumplido tus oportunidades mágicas. ¡Gracias por jugar!', style: const TextStyle(fontSize: 15)),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD85A7F)),
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      gameLauncher();
    }
  }

  void _showTournamentScoresDialog(BuildContext context, TournamentItem tournament) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🏆 Resultados: ${tournament.gameName}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD85A7F))),
        content: SizedBox(
          width: 400,
          height: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🎁 Premio: ${tournament.prize}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2D1B33))),
              const SizedBox(height: 4),
              Text('📜 Reglas: ${tournament.rules}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const Divider(),
              Expanded(
                child: Builder(
                  builder: (context) {
                    tournament.scores.sort((a, b) => a.timeInSeconds.compareTo(b.timeInSeconds));
                    if (tournament.scores.isEmpty) {
                      return const Center(child: Text('Aún no hay participantes registrados en este torneo.'));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: tournament.scores.length,
                      itemBuilder: (context, sIndex) {
                        final score = tournament.scores[sIndex];
                        String medal = sIndex == 0 ? '🥇' : (sIndex == 1 ? '🥈' : (sIndex == 2 ? '🥉' : '✨'));
                        return ListTile(
                          leading: Text(medal, style: const TextStyle(fontSize: 22)),
                          title: Text('${sIndex + 1}. ${score.playerName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Fecha: ${score.date}'),
                          trailing: Text('${score.timeInSeconds.toStringAsFixed(3)} seg', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFD85A7F), fontSize: 15)),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B9D)),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('🎮 Sección de Torneos y Juegos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D1B33))),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Participa en los torneos activos programados por la administración y gana increíbles premios. (Máximo 2 intentos por torneo)', style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 16),

        ValueListenableBuilder<List<TournamentItem>>(
          valueListenable: globalTournamentsNotifier,
          builder: (context, tournaments, child) {
            if (tournaments.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text(
                    'No hay torneos programados por Valentina en este momento. ¡Vuelve pronto!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tournaments.length,
              itemBuilder: (context, index) {
                final t = tournaments[index];
                final now = DateTime.now();
                bool isOngoing = now.isAfter(t.startDate) && now.isBefore(t.endDate);
                bool isUpcoming = now.isBefore(t.startDate);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isOngoing 
                            ? [const Color(0xFFD85A7F), const Color(0xFFFFD93D)] 
                            : [Colors.grey.shade400, Colors.grey.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.emoji_events, color: Colors.white, size: 28),
                                const SizedBox(width: 10),
                                Text(t.gameName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                              ],
                            ),
                            Chip(
                              backgroundColor: Colors.white,
                              label: Text(
                                isOngoing ? '¡En Curso! 🔥' : (isUpcoming ? 'Próximamente ⏳' : 'Finalizado 🏁'),
                                style: TextStyle(
                                  color: isOngoing ? const Color(0xFFD85A7F) : (isUpcoming ? Colors.orange.shade800 : Colors.grey.shade700),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('🎁 Premio: ${t.prize}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('📜 Reglas: ${t.rules}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 6),
                        Text('🕒 Del ${DateFormat('dd/MM/yyyy HH:mm').format(t.startDate)} al ${DateFormat('dd/MM/yyyy HH:mm').format(t.endDate)}', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            if (isOngoing)
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFD85A7F)),
                                  onPressed: () {
                                    if (t.gameName.contains('Concentración')) {
                                      _startGame(context, t, () => showDialog(context: context, barrierDismissible: false, builder: (context) => MemoryGameDialog(tournamentIndex: index)));
                                    } else {
                                      _startGame(context, t, () => showDialog(context: context, barrierDismissible: false, builder: (context) => SpeedDesignGameDialog(tournamentIndex: index)));
                                    }
                                  },
                                  icon: const Icon(Icons.play_arrow, size: 18),
                                  label: const Text('¡Jugar Ahora!', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            if (isOngoing) const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white)),
                                onPressed: () => _showTournamentScoresDialog(context, t),
                                icon: const Icon(Icons.leaderboard, size: 18),
                                label: Text(isOngoing ? 'Tabla de Posiciones' : 'Ver Resultados Finales', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class MemoryGameDialog extends StatefulWidget {
  final int tournamentIndex;
  const MemoryGameDialog({super.key, required this.tournamentIndex});

  @override
  State<MemoryGameDialog> createState() => _MemoryGameDialogState();
}

class _MemoryGameDialogState extends State<MemoryGameDialog> {
  List<_MemoryCard> _cards = [];
  int? _firstFlippedIndex;
  bool _isChecking = false;
  int _matchedPairs = 0;
  
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _elapsedTimeString = '0.000';

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    final products = globalProductsNotifier.value;
    List<ProductItem> pool = List.from(products);
    while (pool.length < 10) {
      pool.addAll(products);
    }
    pool = pool.take(10).toList();

    List<_MemoryCard> tempCards = [];
    for (var p in pool) {
      tempCards.add(_MemoryCard(product: p));
      tempCards.add(_MemoryCard(product: p));
    }
    tempCards.shuffle();
    _cards = tempCards;
    _matchedPairs = 0;
    _firstFlippedIndex = null;

    _stopwatch.reset();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted) {
        setState(() {
          double elapsed = _stopwatch.elapsedMilliseconds / 1000.0;
          _elapsedTimeString = elapsed.toStringAsFixed(3);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _flipCard(int index) {
    if (_isChecking || _cards[index].isFlipped || _cards[index].isMatched) return;

    setState(() {
      _cards[index].isFlipped = true;
    });

    if (_firstFlippedIndex == null) {
      _firstFlippedIndex = index;
    } else {
      int firstIndex = _firstFlippedIndex!;
      _firstFlippedIndex = null;

      if (_cards[firstIndex].product.id == _cards[index].product.id) {
        _cards[firstIndex].isMatched = true;
        _cards[index].isMatched = true;
        _matchedPairs++;
        playMagicChime();

        if (_matchedPairs == 10) {
          _stopwatch.stop();
          _timer?.cancel();
          _saveScore();
        }
      } else {
        _isChecking = true;
        Timer(const Duration(milliseconds: 700), () {
          setState(() {
            _cards[firstIndex].isFlipped = false;
            _cards[index].isFlipped = false;
            _isChecking = false;
          });
        });
      }
    }
  }

  void _saveScore() {
    double finalSeconds = _stopwatch.elapsedMilliseconds / 1000.0;
    final user = globalActiveUserNotifier.value;
    if (user == null) return;

    List<TournamentItem> tournaments = globalTournamentsNotifier.value;
    if (tournaments.length > widget.tournamentIndex) {
      tournaments[widget.tournamentIndex].scores.add(ScoreEntry(
        playerName: user.name,
        timeInSeconds: finalSeconds,
        date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
      ));
      globalTournamentsNotifier.value = List.from(tournaments);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF5F7),
        title: const Text('¡Juego Completado!', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD85A7F))),
        content: Text('Ha completado las 10 parejas, ${user.name}.\n\nTiempo total: ${_elapsedTimeString} segundos.\n\nSu marca ha sido registrada en la tabla del torneo.', style: const TextStyle(fontSize: 15)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD85A7F)),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    '🧩 Concentración Mágica',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D1B33)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, color: Color(0xFFD85A7F), size: 18),
                    const SizedBox(width: 4),
                    Text('$_elapsedTimeString s', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFFD85A7F))),
                  ],
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Text('Parejas encontradas: $_matchedPairs / 10', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.85,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  bool showFront = card.isFlipped || card.isMatched;

                  return GestureDetector(
                    onTap: () => _flipCard(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: showFront ? card.product.color : const Color(0xFFD85A7F),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: Center(
                        child: showFront
                            ? (card.product.imageBytes != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(card.product.imageBytes!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                                      const SizedBox(height: 4),
                                      Text(card.product.name, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold), maxLines: 2),
                                    ],
                                  ))
                            : const Icon(Icons.star, color: Colors.white, size: 30),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryCard {
  ProductItem product;
  bool isFlipped;
  bool isMatched;

  _MemoryCard({required this.product, this.isFlipped = false, this.isMatched = false});
}

class SpeedDesignGameDialog extends StatefulWidget {
  final int tournamentIndex;
  const SpeedDesignGameDialog({super.key, required this.tournamentIndex});

  @override
  State<SpeedDesignGameDialog> createState() => _SpeedDesignGameDialogState();
}

class _SpeedDesignGameDialogState extends State<SpeedDesignGameDialog> {
  List<ProductItem> _targetSequence = [];
  int _currentIndexToFind = 0;
  List<ProductItem> _shuffledGrid = [];

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _elapsedTimeString = '0.000';
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    final products = globalProductsNotifier.value;
    List<ProductItem> pool = List.from(products);
    pool.shuffle();
    
    _targetSequence = pool.take(6).toList();
    _currentIndexToFind = 0;
    _isGameOver = false;

    _shuffledGrid = List.from(_targetSequence);
    _shuffledGrid.shuffle();

    _stopwatch.reset();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted && !_isGameOver) {
        setState(() {
          double elapsed = _stopwatch.elapsedMilliseconds / 1000.0;
          _elapsedTimeString = elapsed.toStringAsFixed(3);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _onProductTap(ProductItem tappedProduct) {
    if (_isGameOver) return;

    if (tappedProduct.id == _targetSequence[_currentIndexToFind].id) {
      playMagicChime();
      setState(() {
        _currentIndexToFind++;
        if (_currentIndexToFind >= _targetSequence.length) {
          _isGameOver = true;
          _stopwatch.stop();
          _timer?.cancel();
          _saveScore();
        } else {
          _shuffledGrid.shuffle();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ese no es el producto correcto. Siga el orden.'), duration: Duration(milliseconds: 600)),
      );
    }
  }

  void _saveScore() {
    double finalSeconds = _stopwatch.elapsedMilliseconds / 1000.0;
    final user = globalActiveUserNotifier.value;
    if (user == null) return;

    List<TournamentItem> tournaments = globalTournamentsNotifier.value;
    if (tournaments.length > widget.tournamentIndex) {
      tournaments[widget.tournamentIndex].scores.add(ScoreEntry(
        playerName: user.name,
        timeInSeconds: finalSeconds,
        date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
      ));
      globalTournamentsNotifier.value = List.from(tournaments);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF5F7),
        title: const Text('¡Reto Superado!', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4ECDC4))),
        content: Text('Completó el reto de velocidad, ${user.name}.\n\nTiempo total: ${_elapsedTimeString} segundos.\n\nSu marca ha sido registrada en la tabla del torneo.', style: const TextStyle(fontSize: 15)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ECDC4)),
            onPressed: () => {
              Navigator.pop(context),
              Navigator.pop(context),
            },
            child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ProductItem nextTarget = _currentIndexToFind < _targetSequence.length ? _targetSequence[_currentIndexToFind] : _targetSequence.last;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    '⚡ Reto de Velocidad y Diseño',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D1B33)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, color: Color(0xFF4ECDC4), size: 18),
                    const SizedBox(width: 4),
                    Text('$_elapsedTimeString s', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF4ECDC4))),
                  ],
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag, color: Color(0xFF4ECDC4), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Busque el siguiente diseño:', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                        Text('${nextTarget.name} (${_currentIndexToFind + 1} / ${_targetSequence.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D1B33))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemCount: _shuffledGrid.length,
                itemBuilder: (context, index) {
                  final product = _shuffledGrid[index];
                  return GestureDetector(
                    onTap: () => _onProductTap(product),
                    child: Container(
                      decoration: BoxDecoration(
                        color: product.color,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            product.imageBytes != null
                                ? Image.memory(product.imageBytes!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                                : const Center(child: Icon(Icons.auto_awesome, color: Colors.white, size: 36)),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                                color: Colors.black.withOpacity(0.5),
                                child: Text(
                                  product.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}