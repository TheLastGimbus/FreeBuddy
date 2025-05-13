import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../headphones/framework/dual_connect.dart';
import '../../../common/list_tile_switch.dart';
import '../../disabled.dart';

class DualConnectCard extends StatelessWidget {
  final DualConnect dualConnect;
  final ExpansionTileController dcListCtrl = ExpansionTileController();

  DualConnectCard(this.dualConnect, {super.key});

  void collapse() => dcListCtrl.collapse();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tt = t.textTheme;
    final l = AppLocalizations.of(context)!;
    final mq = MediaQuery.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamBuilder(
            stream: dualConnect.dualConnectionEnabled,
            initialData: false,
            builder: (_, snap) {
              return Theme(
                data: t.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  controller: dcListCtrl,
                  shape: RoundedRectangleBorder(),
                  title: ListTileSwitch(
                    title: Text(l.dualConnect),
                    value: snap.data!,
                    onChanged: dualConnect.setDualConnectionEnabled,
                  ),
                  children: [
                    const SizedBox(height: 8),
                    _getDevicesList(tt, mq, l),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _getDevicesList(
    TextTheme tt,
    MediaQueryData mq,
    AppLocalizations l,
  ) {
    final stream = dualConnect.dualConnectDevices;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: stream,
          builder: (context, snap) {
            return Row(
              children: [
                if (snap.data?.isNotEmpty ?? false)
                  ...snap.data!.map(
                    (item) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () =>
                            _onDeviceClick(context, stream.share(), item, l),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          height: mq.size.shortestSide * 0.2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                item.connectionState ==
                                        DCConnectionState.playing
                                    ? Icons.bluetooth_audio
                                    : item.connectionState ==
                                            DCConnectionState.connected
                                        ? Icons.bluetooth
                                        : Icons.bluetooth_disabled,
                              ),
                              SizedBox(
                                width: mq.size.shortestSide * 0.2,
                                child: Text(
                                  item.name,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                _getConnStateText(l, item.connectionState),
                                maxLines: 1,
                                style: tt.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getConnStateText(AppLocalizations l, DCConnectionState state) {
    return switch (state) {
      DCConnectionState.playing => l.dualConnectModePlaying,
      DCConnectionState.connected => l.dualConnectModeConnected,
      DCConnectionState.disconnected => l.dualConnectModeOffline,
    };
  }

  void _onDeviceClick(
    BuildContext context,
    Stream<List<DualConnectDevice>> stream,
    DualConnectDevice device,
    AppLocalizations locale,
  ) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 4,
                  margin: EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color
                        ?.withAlpha(0x66),
                    borderRadius: BorderRadius.circular(96),
                  ),
                ),
                StreamBuilder(
                  stream: stream,
                  builder: (_, snap) {
                    device = snap.data?.firstWhere((e) => e.mac == device.mac,
                            orElse: () => device) ??
                        device;

                    return _ConnectionSettingCard(
                      dualConnect,
                      device,
                      locale,
                    );
                  },
                ),
              ],
            ),
          );
        });
  }
}

class _ConnectionSettingCard extends StatefulWidget {
  const _ConnectionSettingCard(this.dualConnect, this.device, this.locale);

  final DualConnect dualConnect;
  final DualConnectDevice device;
  final AppLocalizations locale;

  @override
  State<_ConnectionSettingCard> createState() => _ConnectionSettingCardState();
}

class _ConnectionSettingCardState extends State<_ConnectionSettingCard> {
  DualConnectDevice? device;

  @override
  Widget build(BuildContext context) {
    return Disabled(
      disabled: device?.connectionState == widget.device.connectionState &&
          device?.autoConnect == widget.device.autoConnect &&
          device?.preferred == widget.device.preferred,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(widget.locale.dualConnectDeviceName),
              subtitle: Text(widget.device.name),
            ),
            ListTile(
              title: Text(widget.locale.dualConnectDeviceMac),
              subtitle: Text(widget.device.mac),
            ),
            ListTileSwitch(
              title: Text(widget.locale.dualConnectAutoConnect),
              value: widget.device.autoConnect,
              onChanged: (enabled) async {
                setState(() {
                  device = widget.device;
                });

                await widget.dualConnect
                    .setDeviceAutoConnect(widget.device, enabled);
              },
            ),
            ListTileSwitch(
              title: Text(widget.locale.dualConnectPreferred),
              value: widget.device.preferred,
              onChanged: (enabled) async {
                setState(() {
                  device = widget.device;
                });

                await widget.dualConnect
                    .setDevicePreferred(widget.device, enabled);
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: () async {
                    setState(() {
                      device = widget.device;
                    });

                    await widget.dualConnect.changeDeviceConnectionStatus(
                      widget.device,
                      !(widget.device.connectionState !=
                          DCConnectionState.disconnected),
                    );
                  },
                  child: Text(
                    widget.device.connectionState !=
                            DCConnectionState.disconnected
                        ? widget.locale.dualConnectDisconnect
                        : widget.locale.dualConnectConnect,
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton(
                  onPressed: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: Text(widget.locale.dualConnectUnpair),
                        content: Text(widget.locale.dualConnectUnpairDesc),
                        actions: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(c, false),
                            child: Text(widget.locale.cancel),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(c, true),
                            child: Text(widget.locale.pageIntroQuit),
                          ),
                        ],
                      ),
                    );

                    if (result == true) {
                      await widget.dualConnect.unpairDevice(widget.device);

                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    }
                  },
                  child: Text(widget.locale.dualConnectUnpair),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
