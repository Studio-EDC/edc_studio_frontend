import 'package:edc_studio/api/models/connector.dart';
import 'package:flutter/material.dart';

class ConnectorCard extends StatelessWidget {
  final Connector connector;
  final VoidCallback onToggleState;

  const ConnectorCard({
    super.key,
    required this.connector,
    required this.onToggleState,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRunning = connector.state == 'running';
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      height: isMobile ? null : 140,
      margin: isMobile
          ? const EdgeInsets.symmetric(horizontal: 20, vertical: 8)
          : const EdgeInsets.symmetric(horizontal: 80, vertical: 8),
      padding: isMobile
          ? const EdgeInsets.symmetric(horizontal: 30, vertical: 24)
          : const EdgeInsets.symmetric(horizontal: 50, vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(32),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  connector.name,
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  connector.description ?? '',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${connector.type[0].toUpperCase()}${connector.type.substring(1)} (${connector.mode[0].toUpperCase()}${connector.mode.substring(1)})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),

                Divider(color: Theme.of(context).colorScheme.secondary),

                Row(
                  mainAxisAlignment: connector.mode == 'managed' ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
                  children: [
                    if (connector.mode == 'managed')
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isRunning ? Colors.green : Colors.red,
                          radius: 6,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isRunning ? 'Running' : 'Stopped',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'toggle') onToggleState();
                      },
                      itemBuilder: (context) => [
                        if (connector.mode == 'managed')
                        PopupMenuItem<String>(
                          value: 'toggle',
                          child: Row(
                            children: [
                              Icon(
                                isRunning ? Icons.stop : Icons.play_arrow,
                                color: isRunning ? Colors.red : Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isRunning ? 'Stop' : 'Start',
                                style: TextStyle(
                                  color: isRunning ? Colors.red : Colors.green,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'update',
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Theme.of(context).colorScheme.secondary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'See details',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.secondary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.secondary),
                    ),
                  ],
                )
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        connector.name,
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        connector.description ?? '',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${connector.type[0].toUpperCase()}${connector.type.substring(1)} (${connector.mode[0].toUpperCase()}${connector.mode.substring(1)})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                if (connector.mode == 'managed')
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isRunning ? Colors.green : Colors.red,
                          radius: 6,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isRunning ? 'Running' : 'Stopped',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(width: 50),

                SizedBox(
                  height: 140,
                  child: Align(
                    alignment: Alignment.center,
                    child: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'toggle') onToggleState();
                      },
                      itemBuilder: (context) => [
                        if (connector.mode == 'managed')
                        PopupMenuItem<String>(
                          value: 'toggle',
                          child: Row(
                            children: [
                              Icon(
                                isRunning ? Icons.stop : Icons.play_arrow,
                                color: isRunning ? Colors.red : Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isRunning ? 'Stop' : 'Start',
                                style: TextStyle(
                                  color: isRunning ? Colors.red : Colors.green,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'update',
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Theme.of(context).colorScheme.secondary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'See details',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.secondary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}