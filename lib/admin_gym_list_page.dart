import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:where_gym/admin_gym_list.dart';
import 'package:where_gym/app_bar_factory.dart';
import 'package:where_gym/appointment/appointment_badge.dart';
import 'package:where_gym/appointment/gym_appointment_schedule.dart';
import 'package:where_gym/appointment/gym_appointments_page.dart';
import 'package:where_gym/gen/assets.gen.dart';
import 'package:where_gym/gym.dart';
import 'package:where_gym/shared_appearances.dart';
import 'package:where_gym/tracking/event_names.dart';
import 'package:where_gym/tracking/tracking.dart';

class AdminGymListPage extends StatelessWidget {
  final AdminGymList adminGymList;
  AdminGymListPage(this.adminGymList);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarFactory.appBar(
          title: Text(
        '場租管理',
        style: TextStyles.large.title,
      )),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<List<Gym>>(
      stream: adminGymList.onGyms,
      builder: (context, snap) => _buildList(context, snap.data),
    );
  }

  Widget _buildList(BuildContext context, List<Gym> gyms) {
    if (gyms == null) {
      return Container();
    }
    return ListView.separated(
      padding: EdgeInsets.only(top: 0, bottom: 80),
      itemBuilder: (context, idx) {
        final gym = gyms[idx];
        return _Row(gym);
      },
      separatorBuilder: (context, idx) => Container(
        height: 1,
        color: Colors.grey.shade300,
      ),
      itemCount: gyms.length,
    );
  }
}

class _Row extends StatefulWidget {
  final Gym gym;
  _Row(this.gym);

  @override
  State<_Row> createState() => _RowState();
}

class _RowState extends State<_Row> {
  GymAppointmentSchedule _schedule;

  @override
  void initState() {
    super.initState();
    _schedule = GymAppointmentSchedule(
        appBloc: BlocProvider.of(context), gym: widget.gym);
  }

  void _showDetail(BuildContext context) {
    track(EventName.showGymAppointmentList, {
      ...widget.gym.trackingProps,
      EventProperties.from: 'admin gym list',
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GymAppointmentsPage(gym: widget.gym),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDetail(context),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 120),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 50,
                child: widget.gym.cover == null
                    ? Assets.images.wait.image()
                    : null,
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    image: widget.gym.cover != null
                        ? DecorationImage(
                            image: NetworkImage(widget.gym.cover),
                            fit: BoxFit.cover,
                          )
                        : null),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      widget.gym.name,
                      style: TextStyles.small.header,
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              ),
              SizedBox(width: 8),
              AppointmentBadge(schedule: _schedule),
              SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
