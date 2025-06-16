import 'package:flutter/material.dart';

class BMIPredictionPage extends StatefulWidget {
  const BMIPredictionPage({Key? key}) : super(key: key);

  @override
  State<BMIPredictionPage> createState() => _BMIPredictionPageState();
}

class _BMIPredictionPageState extends State<BMIPredictionPage> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  double? _bmi;
  String _category = '';

  void _calculateBMI() {
    final weight = double.tryParse(_weightController.text);
    final heightCm = double.tryParse(_heightController.text);

    if (weight == null || heightCm == null || weight <= 0 || heightCm <= 0) {
      setState(() {
        _bmi = null;
        _category = "Please enter valid numbers!";
      });
      return;
    }

    final heightM = heightCm / 100;
    final bmi = weight / (heightM * heightM);

    setState(() {
      _bmi = bmi;
      _category = _getBMICategory(bmi);
    });
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 24.9) return "Normal";
    if (bmi < 29.9) return "Overweight";
    return "Obese";
  }

  String _getHealthTips(String category) {
    switch (category) {
      case "Underweight":
        return "Eat more frequently, choose nutrient-rich foods, and incorporate healthy snacks. Consult a healthcare provider for a tailored plan.";
      case "Normal":
        return "Maintain your healthy lifestyle! Continue balanced eating, regular exercise, and periodic health check-ups.";
      case "Overweight":
        return "Focus on portion control, increase your physical activity, and choose lower-calorie nutritious foods.";
      case "Obese":
        return "Adopt a structured weight loss plan under medical supervision, increase daily physical activities, and focus on healthy eating habits.";
      default:
        return "Enter valid data to receive personalized health tips.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "BMI Calculator",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _heightController,
              label: "Height (cm)",
              icon: Icons.height,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _weightController,
              label: "Weight (kg)",
              icon: Icons.monitor_weight,
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _calculateBMI,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Calculate BMI",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (_bmi != null) _buildResultCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildResultCard() {
    String healthTips = _getHealthTips(_category);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your BMI",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _bmi!.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _category,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color:
                    _category == "Normal"
                        ? Colors.green
                        : _category == "Overweight"
                        ? Colors.orange
                        : Colors.redAccent,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Health Tips:",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            healthTips,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
