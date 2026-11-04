import 'package:flutter/material.dart';
import 'package:recetario_utez/presentacion/recetas_view_model.dart';
import 'package:recetario_utez/presentacion/tarjeta_receta.dart';

class RecetasPagina extends StatefulWidget {
  const RecetasPagina({super.key, required this.vm});

  final RecetasViewModel vm;

  @override
  State<RecetasPagina> createState() => _RecetasPaginaState();
}

class _RecetasPaginaState extends State<RecetasPagina> {
  final _controlador = TextEditingController();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _buscar() => widget.vm.buscar(_controlador.text);

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    return Scaffold(
      appBar: AppBar(title: const Text('Recetario UTEZ')),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  key: const Key('busqueda'),
                  controller: _controlador,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _buscar(),
                  decoration: const InputDecoration(
                    labelText: '¿Qué receta buscas?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  key: const Key('buscar'),
                  onPressed: vm.cargando ? null : _buscar,
                  child: const Text('Buscar recetas'),
                ),
                const SizedBox(height: 16),
                Expanded(child: _contenido(vm)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _contenido(RecetasViewModel vm) {
    return switch (vm.estado) {
      RecetasInicial() => const Center(
        child: Text(
          'Escribe una receta o déjalo vacío y toca Buscar recetas.',
          textAlign: TextAlign.center,
        ),
      ),
      RecetasCargando() => const Center(child: CircularProgressIndicator()),
      RecetasVacias(:final busqueda) => Center(
        child: Text(
          busqueda.isEmpty
              ? 'No hay recetas disponibles.'
              : 'No encontramos recetas para "$busqueda".',
          textAlign: TextAlign.center,
        ),
      ),
      RecetasFallidas(:final mensaje) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 8),
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: vm.reintentar,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
      RecetasListas(:final recetas, :final total) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mostrando ${recetas.length} de $total recetas · '
            'Rápidas: ${vm.rapidas}',
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: recetas.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => TarjetaReceta(receta: recetas[i]),
            ),
          ),
        ],
      ),
    };
  }
}
