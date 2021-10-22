import pandas as pd
from matplotlib.figure import Figure
from pandas import DataFrame


def read_list_processing_df() -> DataFrame:
    df = pd.read_csv('../benchmark.csv', header=0)
    df = df.drop(['Description'], axis=1)

    # Conversion from [ns] to [ms]
    df.iloc[:, 2:] = df.iloc[:, 2:] / 1000000

    return df


def calculate_statistics_df(df: DataFrame):
    statistics = df[['Processing', 'Mode']].copy()
    statistics['mean'] = df.mean(axis=1, numeric_only=True)
    statistics['median'] = df.median(axis=1, numeric_only=True)
    statistics['median'] = df.median(axis=1, numeric_only=True)
    statistics['std'] = df.std(axis=1, numeric_only=True)
    return statistics


def get_comparison_df(df: DataFrame):
    list_processing = df.copy().iloc[0:4]
    no_processing = df.copy().iloc[4:6]
    no_processing = no_processing.append(no_processing)

    list_processing['median_difference'] = list_processing['median'] - no_processing['median'].values

    return list_processing


def get_pivot_table(df: DataFrame, value_column: str) -> DataFrame:
    return pd.pivot_table(
        df,
        values=value_column,
        index='Processing',
        columns='Mode')


def add_bar_labels(ax):
    for container in ax.containers:
        ax.bar_label(
            container,
            fmt='%.2f',
            padding=5,
            fontsize=12)


def create_formatted_graph(df_to_display: DataFrame):
    ax = df_to_display.plot.bar(color=['#1954A6', '#65656C', '#B0C92B'])
    # KTH CD colors: https://intra.kth.se/en/administration/kommunikation/grafiskprofil

    ax.get_figure().set_size_inches(10, 6)

    add_bar_labels(ax)

    ax.xaxis.grid(False)
    ax.yaxis.grid(True, color='#EEEEEE')
    ax.set_axisbelow(True)

    for tick in ax.get_xticklabels():
        tick.set_rotation(0)

    ax.xaxis.label.set_fontsize(12)
    ax.yaxis.label.set_fontsize(12)

    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_visible(False)
    ax.spines['bottom'].set_visible(True)

    # ax.set_ylim([0, 500])

    return ax


def create_absolute_graph(df_to_display: DataFrame, no_of_execs: int) -> Figure:
    ax = create_formatted_graph(df_to_display)
    ax.set_xlabel('List processing form')
    ax.set_ylabel('Median duration over {0} executions [ms]'.format(no_of_execs))
    return ax.get_figure()


def create_comparison_graph(df_to_display: DataFrame, no_of_execs: int) -> Figure:
    ax = create_formatted_graph(df_to_display)
    ax.set_xlabel('List processing form')
    ax.set_ylabel("Median duration difference over {0} executions \n when compared to no list processing [ms]".format(no_of_execs))
    return ax.get_figure()


def save_latex_table(df_to_save: DataFrame):
    df_to_save = df_to_save.set_index(['Processing', 'Mode'])
    df_to_save = df_to_save.round(2)
    df_to_save.T.to_latex('statistical-values.tex')


list_processing_df = read_list_processing_df()
statistics_df = calculate_statistics_df(list_processing_df)
comparison_df = get_comparison_df(statistics_df)

save_latex_table(statistics_df)

absolute_pivot_table = get_pivot_table(statistics_df, 'median')
comparison_pivot_table = get_pivot_table(comparison_df, 'median_difference')

execution_columns = list(filter(lambda c: c.startswith('T'), list_processing_df.columns))
no_of_executions = len(execution_columns)

create_absolute_graph(absolute_pivot_table, no_of_executions) \
    .savefig('absolute-graph.png', transparent=True)
create_comparison_graph(comparison_pivot_table, no_of_executions) \
    .savefig('comparison-graph.png', transparent=True)
