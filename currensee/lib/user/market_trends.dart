import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currensee/user/drawer.dart';

class CurrencyNewsPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const CurrencyNewsPage({Key? key, required this.user}) : super(key: key);

  @override
  _CurrencyNewsPageState createState() => _CurrencyNewsPageState();
}

class _CurrencyNewsPageState extends State<CurrencyNewsPage> {
  int _selectedTab = 0; // 0 for News, 1 for Trends

  // Mock data for news articles - you can replace this with API data
  final List<Map<String, dynamic>> _newsArticles = [
    {
      'title': 'US Dollar Strengthens Against Major Currencies',
      'summary': 'The USD shows strong performance amid economic data releases',
      'content': 'The US Dollar Index (DXY) rose 0.5% as investors reacted to positive employment data. EUR/USD fell to 1.0850 while GBP/USD dropped to 1.2650.',
      'image': '💵',
      'date': '2024-01-15',
      'trend': 'up',
      'currency': 'USD'
    },
    {
      'title': 'Euro Zone Inflation Data Impacts EUR Trading',
      'summary': 'Latest inflation figures cause volatility in Euro pairs',
      'content': 'EUR/USD experienced increased volatility following the release of Eurozone inflation data. Traders are adjusting positions ahead of ECB meeting.',
      'image': '💶',
      'date': '2024-01-14',
      'trend': 'down',
      'currency': 'EUR'
    },
    {
      'title': 'Bank of Japan Maintains Ultra-Loose Policy',
      'summary': 'Yen weakens as BOJ keeps negative interest rates',
      'content': 'The Japanese Yen weakened against major currencies after the Bank of Japan decided to maintain its current monetary policy stance.',
      'image': '💴',
      'date': '2024-01-13',
      'trend': 'down',
      'currency': 'JPY'
    },
    {
      'title': 'UK Retail Sales Boost Pound Sterling',
      'summary': 'Better-than-expected retail data supports GBP strength',
      'content': 'GBP/USD climbed to 1.2750 after UK retail sales data exceeded expectations, indicating resilient consumer spending.',
      'image': '💷',
      'date': '2024-01-12',
      'trend': 'up',
      'currency': 'GBP'
    },
    {
      'title': 'Emerging Market Currencies Show Mixed Performance',
      'summary': 'Commodity-linked currencies gain while others struggle',
      'content': 'Currencies like BRL and ZAR gained on commodity price increases, while Asian currencies faced pressure from dollar strength.',
      'image': '🌍',
      'date': '2024-01-11',
      'trend': 'mixed',
      'currency': 'EM'
    },
  ];

  // Mock data for market trends
  final List<Map<String, dynamic>> _marketTrends = [
    {'currency': 'USD', 'rate': 1.0000, 'change': 0.25, 'direction': 'up', 'name': 'US Dollar'},
    {'currency': 'EUR', 'rate': 0.9200, 'change': -0.15, 'direction': 'down', 'name': 'Euro'},
    {'currency': 'GBP', 'rate': 0.7900, 'change': 0.30, 'direction': 'up', 'name': 'British Pound'},
    {'currency': 'JPY', 'rate': 148.50, 'change': -0.45, 'direction': 'down', 'name': 'Japanese Yen'},
    {'currency': 'CAD', 'rate': 1.3500, 'change': 0.10, 'direction': 'up', 'name': 'Canadian Dollar'},
    {'currency': 'AUD', 'rate': 1.5200, 'change': 0.20, 'direction': 'up', 'name': 'Australian Dollar'},
    {'currency': 'CHF', 'rate': 0.8800, 'change': -0.05, 'direction': 'down', 'name': 'Swiss Franc'},
    {'currency': 'CNY', 'rate': 7.1800, 'change': 0.08, 'direction': 'up', 'name': 'Chinese Yuan'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "CurrenSee",
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      drawer: UserDrawer(user: widget.user),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.03),
              theme.colorScheme.primaryContainer.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          children: [
            
            // Tab Bar
            Container(
              color: theme.colorScheme.surface,
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton(0, "News & Analysis", theme),
                  ),
                  Expanded(
                    child: _buildTabButton(1, "Market Trends", theme),
                  ),
                ],
              ),
            ),

            // Content based on selected tab
            Expanded(
              child: _selectedTab == 0 ? _buildNewsTab(theme) : _buildTrendsTab(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int tabIndex, String title, ThemeData theme) {
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedTab = tabIndex;
        });
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: _selectedTab == tabIndex 
            ? theme.colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        shape: const LinearBorder(),
      ),
      child: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: _selectedTab == tabIndex ? FontWeight.bold : FontWeight.normal,
          color: _selectedTab == tabIndex 
              ? theme.colorScheme.primary 
              : theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildNewsTab(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _newsArticles.length,
      itemBuilder: (context, index) {
        final article = _newsArticles[index];
        return _buildNewsCard(article, theme, index);
      },
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> article, ThemeData theme, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showArticleDetail(article, theme),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      article['image'] ?? '📊',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article['title'] ?? '',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          article['date'] ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    article['trend'] == 'up' ? Icons.trending_up : 
                    article['trend'] == 'down' ? Icons.trending_down : Icons.trending_flat,
                    color: article['trend'] == 'up' ? Colors.green : 
                           article['trend'] == 'down' ? Colors.red : Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                article['summary'] ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text(
                      article['currency'] ?? 'GLOBAL',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    backgroundColor: theme.colorScheme.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const Spacer(),
                  Text(
                    'Read More',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendsTab(ThemeData theme) {
    return Column(
      children: [
        // Market Summary Card
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Live Market Summary",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem("Up", _countTrends('up'), Colors.green, theme),
                      _buildSummaryItem("Down", _countTrends('down'), Colors.red, theme),
                      _buildSummaryItem("Total", _marketTrends.length, theme.colorScheme.primary, theme),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Trends List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _marketTrends.length,
            itemBuilder: (context, index) {
              final trend = _marketTrends[index];
              return _buildTrendItem(trend, theme, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, int count, Color color, ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            label == "Up" ? Icons.trending_up : 
            label == "Down" ? Icons.trending_down : Icons.currency_exchange,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendItem(Map<String, dynamic> trend, ThemeData theme, int index) {
    bool isPositive = trend['direction'] == 'up';
    
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPositive 
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
          child: Text(
            trend['currency'] ?? '',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
        ),
        title: Text(
          trend['name'] ?? '',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '1 USD = ${trend['rate']} ${trend['currency']}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isPositive ? '+' : ''}${trend['change']}%',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isPositive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              color: isPositive ? Colors.green : Colors.red,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  int _countTrends(String direction) {
    return _marketTrends.where((trend) => trend['direction'] == direction).length;
  }

  void _showArticleDetail(Map<String, dynamic> article, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Market Analysis",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                article['title'] ?? '',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text(article['currency'] ?? 'GLOBAL'),
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    article['date'] ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                article['content'] ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Close"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}