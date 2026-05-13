import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/district.dart';
import '../providers/library_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_card.dart';
import 'library_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  final List<District> _districts = District.getDistricts();

  static const LatLng _minskCenter = LatLng(53.9006, 27.5590);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onDistrictTap(District district) {
    final locale = Localizations.localeOf(context).languageCode;
    context.read<LibraryProvider>().selectDistrict(district);
    context.read<WeatherProvider>().loadWeather(
          district.center.latitude,
          district.center.longitude,
          lang: locale,
        );
    _mapController.move(district.center, 14);
    _showDistrictPanel(district);
  }

  void _showDistrictPanel(District district) {
    final locale = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.85,
        minChildSize: 0.3,
        builder: (ctx, scrollController) {
          return Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  district.getName(locale),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: WeatherCard(),
              ),
              const SizedBox(height: 8),
              const Divider(),
              Expanded(
                child: Consumer<LibraryProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (provider.filteredLibraries.isEmpty) {
                      return Center(child: Text(l10n.noLibraries));
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: provider.filteredLibraries.length,
                      itemBuilder: (context, index) {
                        final lib = provider.filteredLibraries[index];
                        return ListTile(
                          leading: Icon(Icons.local_library,
                              color: Theme.of(context).colorScheme.primary),
                          title: Text(lib.getName(locale)),
                          subtitle: Text(lib.getAddress(locale)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    LibraryDetailScreen(library: lib),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.map)),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: _minskCenter,
            initialZoom: 12,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.minsk_libraries',
            ),
            PolygonLayer(
              polygons: _districts.map((district) {
                final isSelected =
                    context.watch<LibraryProvider>().selectedDistrict?.id ==
                        district.id;
                return Polygon(
                  points: district.bounds,
                  color: isSelected
                      ? Colors.indigo.withOpacity(0.3)
                      : Colors.blue.withOpacity(0.1),
                  borderColor: isSelected ? Colors.indigo : Colors.blue,
                  borderStrokeWidth: isSelected ? 3.0 : 1.0,
                  isFilled: true,
                );
              }).toList(),
            ),
            MarkerLayer(
              markers: context
                  .watch<LibraryProvider>()
                  .filteredLibraries
                  .map(
                    (lib) => Marker(
                      point: LatLng(lib.latitude, lib.longitude),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                LibraryDetailScreen(library: lib),
                          ),
                        ),
                        child: const Icon(Icons.local_library,
                            color: Colors.red, size: 32),
                      ),
                    ),
                  )
                  .toList(),
            ),
            MarkerLayer(
              markers: _districts
                  .map(
                    (district) => Marker(
                      point: district.center,
                      width: 100,
                      height: 36,
                      child: GestureDetector(
                        onTap: () => _onDistrictTap(district),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          child: Text(
                            district.getName(locale),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
