const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const app = express();
const port =50768; // Choose a port for your server

// MongoDB setup
const uri = 'mongodb://localhost:27017/weatherApp'; // MongoDB URI for local database
mongoose.connect(uri, { useNewUrlParser: true, useUnifiedTopology: true });
const db = mongoose.connection;
db.once('open', () => {
    console.log('Database connected');
});

// Schema for city
const citySchema = new mongoose.Schema({
    name: { type: String, required: true },
    datetime: { type: Date, required: true },
    temperature: { type: Number, required: true },
    humidity: { type: Number, required: true },
    windSpeed: { type: Number, required: true },
    visibility: { type: Number, required: true },
    weatherType: { type: String, required: true },
    imagePath: { type: String, required: true }
});
const City = mongoose.model('City', citySchema);

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors());

// Routes
app.post('/addCity', async (req, res) => {
    try {
        const { name, datetime, temperature, humidity, windSpeed, visibility, weatherType, imagePath } = req.body;
        
        // Log the received data
        console.log('Received data:', req.body);

        const newCity = new City({ name, datetime: new Date(datetime), temperature, humidity, windSpeed, visibility, weatherType, imagePath });
        await newCity.save();
        console.log('City added:', newCity);
        res.status(200).send('City added successfully');
    } catch (error) {
        console.error('Error adding city:', error);
        res.status(500).send('Error adding city');
    }
});

app.get('/getCities', async (req, res) => {
    try {
        const cities = await City.find();
        console.log('Cities fetched:', cities);
        res.status(200).json(cities);
    } catch (error) {
        console.error('Error fetching cities:', error);
        res.status(500).send('Error fetching cities' + error.message);
    }
});

app.delete('/deleteCity/:name', async (req, res) => {
    try {
      const cityName = req.params.name;
      await City.deleteOne({ name: cityName });
      console.log('City deleted:', cityName);
      res.status(200).send('City deleted successfully');
    } catch (error) {
      console.error('Error deleting city:', error);
      res.status(500).send('Error deleting city');
    }
  });
  
// Start server
app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});
