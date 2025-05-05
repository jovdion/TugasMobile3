import 'dart:async';
import 'package:flutter/material.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({Key? key}) : super(key: key);

  @override
  _StopwatchScreenState createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  late Stopwatch _stopwatch;
  late Timer _timer;
  List<LapTime> _laps = [];
  bool _isRunning = false;
  bool _isStopped = false;
  String _currentTime = "00:00.00";
  String _currentMicroseconds = "";

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(const Duration(milliseconds: 30), _updateTime);
  }

  void _updateTime(Timer timer) {
    if (_stopwatch.isRunning) {
      setState(() {
        _setCurrentTime();
      });
    }
  }

  void _setCurrentTime() {
    final milliseconds = _stopwatch.elapsedMilliseconds;
    final hundreds = (milliseconds % 1000) ~/ 10;
    final seconds = (milliseconds ~/ 1000) % 60;
    final minutes = (milliseconds ~/ (1000 * 60)) % 60;
    final hours = (milliseconds ~/ (1000 * 60 * 60));

    _currentTime = hours > 0 
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    _currentMicroseconds = '.${hundreds.toString().padLeft(2, '0')}';
  }

  void _start() {
    setState(() {
      _stopwatch.start();
      _isRunning = true;
      _isStopped = false;
    });
  }
  
  void _stop() {
    setState(() {
      _stopwatch.stop();
      _isRunning = false;
      _isStopped = true;
    });
  }
  
  void _continue() {
    setState(() {
      _stopwatch.start();
      _isRunning = true;
      _isStopped = false;
    });
  }

  void _reset() {
    setState(() {
      _stopwatch.reset();
      _laps.clear();
      _currentTime = "00:00.00";
      _currentMicroseconds = "";
      _isRunning = false;
      _isStopped = false;
    });
  }

  void _addLap() {
    if (_stopwatch.isRunning) {
      final currentLapTime = _stopwatch.elapsedMilliseconds;
      final previousLapTime = _laps.isEmpty ? 0 : _laps[0].totalTimeMs;
      final lapDuration = currentLapTime - previousLapTime;
      
      // Format lap time
      final lapHundreds = (lapDuration % 1000) ~/ 10;
      final lapSeconds = (lapDuration ~/ 1000) % 60;
      final lapMinutes = (lapDuration ~/ (1000 * 60)) % 60;
      final lapHours = (lapDuration ~/ (1000 * 60 * 60));
      
      String lapTimeFormatted = lapHours > 0 
          ? '${lapHours.toString().padLeft(2, '0')}:${lapMinutes.toString().padLeft(2, '0')}:${lapSeconds.toString().padLeft(2, '0')}.${lapHundreds.toString().padLeft(2, '0')}'
          : '${lapMinutes.toString().padLeft(2, '0')}:${lapSeconds.toString().padLeft(2, '0')}.${lapHundreds.toString().padLeft(2, '0')}';
      
      // Format total time
      final totalHundreds = (currentLapTime % 1000) ~/ 10;
      final totalSeconds = (currentLapTime ~/ 1000) % 60;
      final totalMinutes = (currentLapTime ~/ (1000 * 60)) % 60;
      final totalHours = (currentLapTime ~/ (1000 * 60 * 60));
      
      String totalTimeFormatted = totalHours > 0 
          ? '${totalHours.toString().padLeft(2, '0')}:${totalMinutes.toString().padLeft(2, '0')}:${totalSeconds.toString().padLeft(2, '0')}.${totalHundreds.toString().padLeft(2, '0')}'
          : '${totalMinutes.toString().padLeft(2, '0')}:${totalSeconds.toString().padLeft(2, '0')}.${totalHundreds.toString().padLeft(2, '0')}';
      
      setState(() {
        _laps.insert(0, LapTime(
          lapNumber: _laps.isEmpty ? 1 : _laps.length + 1,
          lapTime: lapTimeFormatted,
          totalTime: totalTimeFormatted,
          totalTimeMs: currentLapTime,
        ));
      });
    }
  }

  void _removeLap(int index) {
    final removedLap = _laps[index];
    setState(() {
      _laps.removeAt(index);
      
      // Update lap numbers for remaining laps
      for (int i = 0; i < _laps.length; i++) {
        if (_laps[i].lapNumber > removedLap.lapNumber) {
          _laps[i] = LapTime(
            lapNumber: _laps[i].lapNumber - 1,
            lapTime: _laps[i].lapTime,
            totalTime: _laps[i].totalTime,
            totalTimeMs: _laps[i].totalTimeMs,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text(
          'Stopwatch',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: _laps.isNotEmpty ? [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear all laps',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear all laps?'),
                  content: const Text('This will remove all saved lap times.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _laps.clear();
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('CLEAR'),
                    ),
                  ],
                ),
              );
            },
          ),
        ] : null,
      ),
      body: Column(
        children: [
          // Timer display
          if (_laps.isEmpty)
            Expanded(
              flex: 2,
              child: Center(
                child: _buildTimerDisplay(),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: _buildTimerDisplay(),
            ),
          
          // Lap times
          if (_laps.isNotEmpty)
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const SizedBox(width: 40, child: Text('Lap', style: TextStyle(fontWeight: FontWeight.bold))),
                          const Expanded(
                            child: Center(
                              child: Text('Lap Time', style: TextStyle(fontWeight: FontWeight.bold)),
                            )
                          ),
                          const Expanded(
                            child: Center(
                              child: Text('Overall', style: TextStyle(fontWeight: FontWeight.bold)),
                            )
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    
                    // Lap list
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _laps.length,
                        itemBuilder: (context, index) {
                          final lap = _laps[index];
                          final isNewest = index == 0;
                          final isOldest = index == _laps.length - 1;
                          
                          return Dismissible(
                            key: Key('lap_${lap.lapNumber}_${lap.totalTimeMs}'),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Colors.red,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              _removeLap(index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Lap ${lap.lapNumber} deleted'),
                                  duration: const Duration(seconds: 2),
                                  action: SnackBarAction(
                                    label: 'UNDO',
                                    onPressed: () {
                                      setState(() {
                                        _laps.insert(index, lap);
                                        // Restore other lap numbers if needed
                                        for (int i = 0; i < _laps.length; i++) {
                                          if (i != index && _laps[i].lapNumber >= lap.lapNumber) {
                                            _laps[i] = LapTime(
                                              lapNumber: _laps[i].lapNumber + 1,
                                              lapTime: _laps[i].lapTime,
                                              totalTime: _laps[i].totalTime,
                                              totalTimeMs: _laps[i].totalTimeMs,
                                            );
                                          }
                                        }
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              color: isNewest ? Colors.blue.withOpacity(0.05) : null,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                child: Row(
                                  children: [
                                    // Lap number
                                    SizedBox(
                                      width: 40,
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: isNewest ? Colors.blue.withOpacity(0.1) : 
                                                 isOldest ? Colors.orange.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${lap.lapNumber}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isNewest ? Colors.blue : 
                                                   isOldest ? Colors.orange : Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    // Lap time
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          lap.lapTime,
                                          style: TextStyle(
                                            fontFamily: 'monospace',
                                            fontWeight: isNewest ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    // Total time
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          lap.totalTime,
                                          style: TextStyle(
                                            fontFamily: 'monospace',
                                            fontWeight: isNewest ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    // Delete button
                                    SizedBox(
                                      width: 40,
                                      child: IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 20),
                                        padding: EdgeInsets.zero,
                                        color: Colors.red.withOpacity(0.7),
                                        onPressed: () {
                                          _removeLap(index);
                                        },
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
            ),
          
          // Control buttons at the bottom
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Left button (Start/Stop/Continue)
                Expanded(
                  child: _buildMainButton(),
                ),
                const SizedBox(width: 20),
                // Right button (Lap/Reset)
                Expanded(
                  child: _buildSecondaryButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimerDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            _currentTime,
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w500,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            _currentMicroseconds,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w400,
              fontFamily: 'monospace',
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton() {
    if (_isRunning) {
      // Show Stop button
      return ElevatedButton(
        onPressed: _stop,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 3,
        ),
        child: const Text(
          'STOP',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (_isStopped) {
      // Show Continue button
      return ElevatedButton(
        onPressed: _continue,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 3,
        ),
        child: const Text(
          'CONTINUE',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      // Show Start button
      return ElevatedButton(
        onPressed: _start,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 3,
        ),
        child: const Text(
          'START',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  Widget _buildSecondaryButton() {
    if (_isRunning) {
      // Show Lap button
      return ElevatedButton(
        onPressed: _addLap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 3,
        ),
        child: const Text(
          'LAP',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (_isStopped) {
      // Show Reset button
      return ElevatedButton(
        onPressed: _reset,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 3,
        ),
        child: const Text(
          'RESET',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      // Show Lap button (disabled)
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          foregroundColor: Colors.grey[500],
          disabledBackgroundColor: Colors.grey[200],
          disabledForegroundColor: Colors.grey[400],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 1,
        ),
        child: const Text(
          'LAP',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }
}

class LapTime {
  final int lapNumber;
  final String lapTime;
  final String totalTime;
  final int totalTimeMs;
  
  LapTime({
    required this.lapNumber,
    required this.lapTime,
    required this.totalTime,
    required this.totalTimeMs,
  });
}
