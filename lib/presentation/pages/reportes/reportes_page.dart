import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ReportesPage extends StatefulWidget {
  const ReportesPage({Key? key}) : super(key: key);

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<double> ingresos = [1200, 1350, 1600, 1100, 1800, 2100, 2400];
  final List<double> gastos = [900, 800, 1200, 1000, 1300, 1500, 1700];
  final List<String> dias = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  bool _mostrarDetallesIngresos = false;
  bool _mostrarDetallesGastos = false;
  bool _mostrarDetallesBalance = false;

  List<bool> _expandirDia = List.generate(7, (_) => false);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generarPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📄 Generando reporte PDF...'),
        backgroundColor: Color(0xFF3F51B5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formato = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final totalIngresos = ingresos.reduce((a, b) => a + b);
    final totalGastos = gastos.reduce((a, b) => a + b);
    final balance = totalIngresos - totalGastos;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F51B5),
        elevation: 6,
        title: const Text("Reporte Financiero"),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildResumenCard(formato, totalIngresos, totalGastos, balance),
              const SizedBox(height: 20),
              _buildGrafico(),
              const SizedBox(height: 25),
              _buildBotonPDF(),
              const SizedBox(height: 30),
              _buildDetalles(formato),
            ],
          ),
        ),
      ),
    );
  }

  // 🌟 TARJETA DE RESUMEN
  Widget _buildResumenCard(
    NumberFormat formato,
    double ingresos,
    double gastos,
    double balance,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3F51B5), Colors.black87],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Text(
              "Resumen del Mes 💰",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _expandableInfoBox(
              "Ingresos del mes",
              formato.format(ingresos),
              Colors.greenAccent,
              _mostrarDetallesIngresos,
              () => setState(
                () => _mostrarDetallesIngresos = !_mostrarDetallesIngresos,
              ),
              ["Pago freelance: \$450", "Venta: \$780", "Comisión: \$320"],
            ),
            _expandableInfoBox(
              "Gastos del mes",
              formato.format(gastos),
              Colors.redAccent,
              _mostrarDetallesGastos,
              () => setState(
                () => _mostrarDetallesGastos = !_mostrarDetallesGastos,
              ),
              ["Alquiler: \$650", "Comida: \$420", "Servicios: \$180"],
            ),
            _expandableInfoBox(
              "Balance actual",
              formato.format(balance),
              Colors.white,
              _mostrarDetallesBalance,
              () => setState(
                () => _mostrarDetallesBalance = !_mostrarDetallesBalance,
              ),
              [
                "Saldo cuenta: \$1,200",
                "Meta ahorro: \$800",
                "Pendiente: \$200",
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _expandableInfoBox(
    String label,
    String value,
    Color color,
    bool expanded,
    VoidCallback onTap,
    List<String> ejemplos,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            title: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children:
                  ejemplos
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 6,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 8,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  e,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 400),
          ),
        ],
      ),
    );
  }

  // 📈 GRÁFICO MEJORADO FINAL (con animación tipo login)
  Widget _buildGrafico() {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _controller, // Usa el mismo AnimationController del login
        curve: Curves.easeInOut,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOut,
        height: 260,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3F51B5), Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOut,
          builder: (context, animValue, child) {
            return Opacity(
              opacity: animValue,
              child: Transform.scale(
                scale: 0.96 + (animValue * 0.04),
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: 2500,
                    gridData: FlGridData(
                      show: true,
                      getDrawingHorizontalLine:
                          (v) => FlLine(color: Colors.white12, strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 42,
                          getTitlesWidget:
                              (v, meta) => Text(
                                '\$${v.toInt()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, meta) {
                            int i = v.toInt();
                            if (i < 0 || i >= dias.length)
                              return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                dias[i],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          ingresos.length,
                          (i) => FlSpot(i.toDouble(), ingresos[i] * animValue),
                        ),
                        isCurved: true,
                        color: const Color(0xFF80DEEA), // Azul celeste
                        barWidth: 4,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFF80DEEA).withOpacity(0.25),
                        ),
                      ),
                      LineChartBarData(
                        spots: List.generate(
                          gastos.length,
                          (i) => FlSpot(i.toDouble(), gastos[i] * animValue),
                        ),
                        isCurved: true,
                        color: const Color(0xFFFF6E40), // Naranja suave
                        barWidth: 4,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFFFF6E40).withOpacity(0.25),
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
    );
  }

  // 📄 BOTÓN PDF
  Widget _buildBotonPDF() {
    return ElevatedButton.icon(
      onPressed: _generarPDF,
      icon: const Icon(Icons.picture_as_pdf, size: 24),
      label: const Text(
        "Descargar Reporte PDF",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 6,
      ),
    );
  }

  // 📅 DETALLES DIARIOS
  Widget _buildDetalles(NumberFormat formato) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Detalles Diarios",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        ...List.generate(dias.length, (i) {
          final balance = ingresos[i] - gastos[i];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              child: ExpansionTile(
                initiallyExpanded: _expandirDia[i],
                onExpansionChanged: (val) {
                  setState(() => _expandirDia[i] = val);
                },
                leading: CircleAvatar(
                  backgroundColor:
                      balance >= 0 ? const Color(0xFF3F51B5) : Colors.redAccent,
                  child: Icon(
                    balance >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  "Día ${dias[i]}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  "Ingresos: ${formato.format(ingresos[i])} | Gastos: ${formato.format(gastos[i])}",
                  style: const TextStyle(color: Colors.black54),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        _detalleItem(
                          Icons.attach_money,
                          "Ingreso principal: Pago de cliente 💼",
                          Colors.green,
                        ),
                        _detalleItem(
                          Icons.shopping_cart,
                          "Gasto: Compra de materiales 🛒",
                          Colors.redAccent,
                        ),
                        _detalleItem(
                          Icons.restaurant,
                          "Gasto: Almuerzo 🍱",
                          Colors.orangeAccent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _detalleItem(IconData icon, String texto, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(texto, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }
}
