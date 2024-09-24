import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../logic/history/history_bloc.dart';
import '../../api/api.dart'; // Import the API

class HistoricalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historical Data'),
      ),
      body: BlocProvider(
        create: (context) => HistoryBloc(),
        child: HistoricalForm(),
      ),
    );
  }
}

class HistoricalForm extends StatefulWidget {
  @override
  _HistoricalFormState createState() => _HistoricalFormState();
}

class _HistoricalFormState extends State<HistoricalForm> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(labelText: 'City Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a city name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _startDateController,
              decoration: InputDecoration(labelText: 'Start Date (yyyy-MM-dd)'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a start date';
                }
                if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                  return 'Please enter a valid date (yyyy-MM-dd)';
                }
                return null;
              },
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  _startDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                }
              },
            ),
            TextFormField(
              controller: _endDateController,
              decoration: InputDecoration(labelText: 'End Date (yyyy-MM-dd)'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an end date';
                }
                if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                  return 'Please enter a valid date (yyyy-MM-dd)';
                }
                return null;
              },
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  _endDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Fetch latitude and longitude based on the city name
                  final locations = await getLatLongFromPlace(_cityController.text);
                  if (locations.isNotEmpty) {
                    final lat = locations[0]['lat'];
                    final lng = locations[0]['lng'];
                    final startTime = "${_startDateController.text}T00:00:00Z";
                    final endTime = "${_endDateController.text}T23:59:59Z";
                    // Fetch historical data based on the form inputs
                    BlocProvider.of<HistoryBloc>(context).add(
                      FetchHistory(lat, lng, startTime, endTime),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('City not found')),
                    );
                  }
                }
              },
              child: Text('Fetch Historical Data'),
            ),
            Expanded(
              child: BlocBuilder<HistoryBloc, HistoryState>(
                builder: (context, state) {
                  if (state is HistoryLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is HistoryFailure) {
                    return Center(child: Text('Failed to fetch historical data.'));
                  } else if (state is HistorySuccess) {
                    return _buildHistoricalContent(state.data);
                  }
                  return Center(child: Text('Enter a place to get historical data.'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoricalContent(Map<String, dynamic> data) {
    if (data == null || data['timelines'] == null || data['timelines']['hourly'] == null) {
      return Center(child: Text('No historical data available.'));
    }

    return ListView.builder(
      itemCount: data['timelines']['hourly'].length,
      itemBuilder: (context, index) {
        final item = data['timelines']['hourly'][index];
        return ListTile(
          title: Text('Time: ${item['time']}'),
          subtitle: Text('Temperature: ${item['values']['temperature']} °C'),
        );
      },
    );
  }
}