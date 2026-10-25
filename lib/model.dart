import 'dart:math' as math;

class Question {
  final String question;
  final List<String> possibleAnswers;
  final int correctAnswer;

  Question(this.question, this.possibleAnswers, this.correctAnswer);
}

class QuestionBank {
  final List<Question> _questions = _createQuestions();

  bool get hasNextQuestion => _questions.isNotEmpty;
  int get remainingQuestions => _questions.length;

  Question? getRandomQuestion() {
    if (_questions.isEmpty) return null;
    final i = math.Random().nextInt(_questions.length);
    final question = _questions[i];
    _questions.removeAt(i);
    return question;
  }
}

List<Question> _createQuestions() {
  return [
    Question(
      'Widget apa yang digunakan untuk membuat animasi implisit di Flutter?',
      ['AnimatedContainer', 'AnimationController', 'CustomPainter', 'Transform'],
      0,
    ),
    Question(
      'Class apa yang digunakan untuk membuat dan mengontrol animasi eksplisit?',
      ['TweenSequence', 'AnimatedBuilder', 'AnimationController', 'Interval'],
      2,
    ),
    Question(
      'Curve mana yang menghasilkan efek "memantul" atau springy?',
      ['Curves.linear', 'Curves.easeIn', 'Curves.decelerate', 'Curves.elasticOut'],
      3,
    ),
    Question(
      'Widget apa yang digunakan untuk merender ulang child setiap kali nilai animasi berubah?',
      ['AnimatedOpacity', 'AnimationController', 'AnimatedBuilder', 'AnimatedSwitcher'],
      2,
    ),
    Question(
      'Apa fungsi dari Tween dalam sistem animasi Flutter?',
      [
        'Menentukan durasi animasi',
        'Menentukan nilai awal dan akhir animasi',
        'Mengontrol kecepatan frame',
        'Membuat widget baru secara otomatis',
      ],
      1,
    ),
    Question(
      'Widget apa yang digunakan untuk transisi otomatis antar dua widget berbeda?',
      ['Navigator', 'Stack', 'AnimatedSwitcher', 'Opacity'],
      2,
    ),
    Question(
      'Apa arti "vsync" pada AnimationController di Flutter?',
      [
        'Kecepatan maksimum animasi',
        'Jumlah pengulangan animasi',
        'Sinkronisasi dengan refresh rate layar',
        'Arah animasi (maju/mundur)',
      ],
      2,
    ),
  ];
}
