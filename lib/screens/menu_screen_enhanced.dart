import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/auth_service.dart';
import '../services/preferences_service.dart';
import 'login_screen.dart';

class MenuScreenEnhanced extends StatefulWidget {
  const MenuScreenEnhanced({super.key});

  @override
  State<MenuScreenEnhanced> createState() => _MenuScreenEnhancedState();
}

class _MenuScreenEnhancedState extends State<MenuScreenEnhanced> {
  final _productService = ProductService();
  final _authService = AuthService();
  final _searchController = TextEditingController();
  String? _currentUserId;
  bool _isLoading = true;
  String _sortBy = 'date'; // 'date', 'price', 'name', 'quantity'
  String _filterBy = 'all'; // 'all', 'low_stock', 'high_price'

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userData = await PreferencesService.getUserData();
    setState(() {
      _currentUserId = userData?['userId'];
      _isLoading = false;
    });
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la déconnexion: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<ProductModel> _filterAndSort(List<ProductModel> products) {
    var filtered = products;

    // Filtre par recherche
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query);
      }).toList();
    }

    // Filtre par stock/prix
    if (_filterBy == 'low_stock') {
      filtered = filtered.where((p) => p.quantity < 10).toList();
    } else if (_filterBy == 'high_price') {
      filtered = filtered.where((p) => p.price > 1000).toList();
    }

    // Tri
    switch (_sortBy) {
      case 'price':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'quantity':
        filtered.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      case 'date':
      default:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return filtered;
  }

  Map<String, dynamic> _calculateStats(List<ProductModel> products) {
    if (products.isEmpty) {
      return {
        'total': 0,
        'totalValue': 0.0,
        'averagePrice': 0.0,
        'lowStock': 0,
      };
    }

    final totalValue = products.fold<double>(
      0.0,
      (sum, p) => sum + (p.price * p.quantity),
    );
    final averagePrice = totalValue / products.length;
    final lowStock = products.where((p) => p.quantity < 10).length;

    return {
      'total': products.length,
      'totalValue': totalValue,
      'averagePrice': averagePrice,
      'lowStock': lowStock,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes Produits',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: _productService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          final allProducts = snapshot.data ?? [];
          final products = _filterAndSort(allProducts);
          final stats = _calculateStats(allProducts);

          return Column(
            children: [
              // Statistiques
              if (allProducts.isNotEmpty)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        icon: Icons.inventory_2,
                        label: 'Total',
                        value: '${stats['total']}',
                        color: Colors.blue,
                      ),
                      _StatItem(
                        icon: Icons.attach_money,
                        label: 'Valeur',
                        value: '${stats['totalValue'].toStringAsFixed(0)} FC',
                        color: Colors.green,
                      ),
                      _StatItem(
                        icon: Icons.trending_up,
                        label: 'Moyenne',
                        value: '${stats['averagePrice'].toStringAsFixed(0)} FC',
                        color: Colors.orange,
                      ),
                      _StatItem(
                        icon: Icons.warning,
                        label: 'Stock bas',
                        value: '${stats['lowStock']}',
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),

              // Barre de recherche et filtres
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher un produit...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _sortBy,
                            decoration: InputDecoration(
                              labelText: 'Trier par',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'date',
                                child: Text('Date (récent)'),
                              ),
                              DropdownMenuItem(
                                value: 'price',
                                child: Text('Prix (élevé)'),
                              ),
                              DropdownMenuItem(
                                value: 'name',
                                child: Text('Nom (A-Z)'),
                              ),
                              DropdownMenuItem(
                                value: 'quantity',
                                child: Text('Quantité'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _sortBy = value ?? 'date';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _filterBy,
                            decoration: InputDecoration(
                              labelText: 'Filtrer',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'all',
                                child: Text('Tous'),
                              ),
                              DropdownMenuItem(
                                value: 'low_stock',
                                child: Text('Stock bas'),
                              ),
                              DropdownMenuItem(
                                value: 'high_price',
                                child: Text('Prix élevé'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _filterBy = value ?? 'all';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Liste des produits
              Expanded(
                child: products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              allProducts.isEmpty
                                  ? 'Aucun produit'
                                  : 'Aucun résultat',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              allProducts.isEmpty
                                  ? 'Ajoutez votre premier produit'
                                  : 'Essayez une autre recherche',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return _ProductCardEnhanced(
                            product: product,
                            onEdit: () {
                              // TODO: Implémenter l'édition
                            },
                            onDelete: () async {
                              try {
                                await _productService.deleteProduct(product.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Produit supprimé'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erreur: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implémenter l'ajout
        },
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Ajouter',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _ProductCardEnhanced extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCardEnhanced({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.quantity < 10;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ),
                          if (isLowStock)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red),
                              ),
                              child: const Text(
                                'Stock bas',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: Color(0xFF6366F1)),
                  onPressed: onEdit,
                  tooltip: 'Modifier',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Supprimer le produit'),
                        content: const Text(
                          'Êtes-vous sûr de vouloir supprimer ce produit?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onDelete();
                            },
                            child: const Text(
                              'Supprimer',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  tooltip: 'Supprimer',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.attach_money,
                  label: '${product.price.toStringAsFixed(2)} FC',
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _InfoChip(
                  icon: Icons.inventory_2,
                  label: '${product.quantity} unités',
                  color: isLowStock ? Colors.red : Colors.blue,
                ),
                const SizedBox(width: 12),
                _InfoChip(
                  icon: Icons.calculate,
                  label: '${(product.price * product.quantity).toStringAsFixed(0)} FC',
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ajouté le ${_formatDate(product.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

